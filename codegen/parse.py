from codegen_types import *
from annotations import *

def strip_all(strings: list[str]) -> list[str]:
    return list(map(
        lambda string: string.strip(),
        strings
    ))

class Parser:
    def __init__(self, fname: str):
        self.fname = fname

    def parse(self) -> ParsedGenFile:
        contents: list[str]
        with open(self.fname, "rt") as fh:
            contents = fh.readlines()
        
        out = ParsedGenFile(
            self.fname,
            [], [], [], [], []
        )

        skip = 0
        annotations: list[CodegenAnnotation] = []
        for i, line in enumerate(contents):
            if skip:
                skip -= 1
                continue

            if line.startswith("//"):
                continue

            if line.isspace():
                # if we've had any annotations & they're followed by whitespace,
                # they apply to the whole file.
                out.annotations += annotations
                annotations = []

                continue
            
            if line.startswith("struct"):
                raise ValueError("Structs aren't a thing anymore, fuck off")
                struct = self.get_part(contents, i)
                out.structs.append(
                    self.parse_struct(
                        struct,
                        annotations
                    )
                )
                annotations = []
                skip = len(struct) - 1

            elif line.startswith("enum"):
                enum = self.get_part(contents, i)
                out.enums.append(
                    self.parse_enum(
                        enum,
                        annotations
                    )
                )
                annotations = []
                skip = len(enum) - 1

            elif line.startswith("class"):
                class_ = self.get_part(contents, i)
                out.classes.append(
                    self.parse_class(
                        class_,
                        annotations
                    )
                )
                annotations = []
                skip = len(class_) - 1

            elif line.startswith("@"):
                annotations.append(
                    self.parse_annotation(line)
                )
            
            else:
                out.functions.append(
                    self.parse_function(
                        line,
                        annotations
                    )
                )
        
        return out
    

    # get lines between i and "}"
    def get_part(self, contents: list[str], i: int):
        try:
            close_bracket_idx = contents[i:].index("}\n")
        except ValueError:
            # could be one at the end of the file with no newline after
            try:
                close_bracket_idx = contents[i:].index('}')
            except ValueError:
                print("Closing bracket not found")
                print(f"Open bracket in {self.fname}, line {i+1}: {contents[i]}")
                raise
        return contents[i:
            i + close_bracket_idx + 1
        ]
    

    # "class SomeClass {\n" => "SomeClass"
    def get_structure_name(self, structure_type: str, structure_decl: str) -> str:
        return structure_decl[len(structure_type) + 1:][:-2].strip()
    
    # decl should be something like "int *varName"
    def to_codegen_type(self, decl: str) -> tuple[CodegenType, str]:
        is_pointer = "*" in decl
        if is_pointer:
            typename, name = strip_all(decl.split("*"))
        else:
            typename, name = decl.split(" ")

        return CodegenType(
            typename,
            is_pointer
        ), name

    def parse_annotation(self, annotation: str) -> CodegenAnnotation:
        assert "(" in annotation, "Annotations must end with parentheses, even if they have no arguments."

        name, args_raw = annotation[1:].split("(")
        args: list[str] = []
        if not args_raw == ")\n":
            args = strip_all(
                # used to be -2, is there a newline issue?
                args_raw[:-1].split(",")
            )
        return CodegenAnnotation(
            name,
            args
        )

    
    def parse_function(self, function: str, annotations: list[CodegenAnnotation]) -> CodegenFunction:
        if not function.endswith("\n"): function += "\n"

        name_and_return_type, params_raw = function.split("(")

        return_type, name = self.to_codegen_type(name_and_return_type)
        
        params: dict[str, CodegenType] = {}
        if not params_raw == ");\n":
            for param in params_raw[:-3].split(","):
                param_type, param_name = self.to_codegen_type(param.strip())
                params[param_name] = param_type
        
        return CodegenFunction(
            name,
            return_type,
            params,
            annotations
        )


    # struct can contain:
    #   - whitespace
    #   - comments
    #   - members
    #   - annotations for members
    def parse_struct(self, struct: list[str], annotations: list[CodegenAnnotation]) -> CodegenStruct:
        name = self.get_structure_name("struct", struct[0])
        # we don't want the first or last line
        contents = struct[1:-1]

        out = CodegenStruct(name, [], annotations)

        current_annotations: list[CodegenAnnotation] = []
        for line in strip_all(contents):
            if line.startswith("//"):
                continue
            
            if line == '':
                if len(current_annotations) > 0:
                    raise ValueError(
                        f"Whitespace after annotations in a struct - which member do these annotations apply to?\n{current_annotations}\n" + 
                        "To apply annotations to the whole struct, place them directly before the struct definition."
                    )
                continue
            
            if line.startswith("@"):
                current_annotations.append(
                    self.parse_annotation(line)
                )
            
            else:
                field_type, field_name = self.to_codegen_type(line[:-1])
                out.fields.append(
                    CodegenDataStructureField(
                        field_name,
                        field_type,
                        current_annotations
                    )
                )
                current_annotations = []
        
        return out
            

    def parse_enum(self, enum: list[str], annotations: list[CodegenAnnotation]) -> CodegenEnum:
        name = self.get_structure_name("enum", enum[0])
        contents = enum[1:-1]
        out = CodegenEnum(name, [], annotations)

        # possible states:
        #   - comment
        #   - whitespace
        #   - val, // stringify
        #   - val  // stringify
        #   - val,
        #   - val
        # no annotations
        for line in strip_all(contents):
            if line.startswith('//') or line == '':
                continue
            
            if '//' in line:
                val_name, stringify = strip_all(line.split('//'))
                if "," in val_name:
                    val_name = val_name[:val_name.find(",")]
            elif ',' in line:
                val_name = stringify = line[:line.find(',')]
            else:
                val_name = stringify = line
            
            out.values.append(
                CodegenEnumValue(
                    val_name,
                    stringify,
                )
            )

        return out

    def parse_class(self, class_: list[str], annotations: list[CodegenAnnotation]) -> CodegenClass:
        name = self.get_structure_name("class", class_[0])
        contents = class_[1:-1]

        out = CodegenClass(name, [], [], annotations)

        # lots of possibilities!!
        #   - whitespace, clear annotations etc etc
        #   - comment
        #   - annotation
        #   - field
        #   - method
        current_annotations: list[CodegenAnnotation] = []
        for line in strip_all(contents):
            if line.startswith('//'):
                continue
                
            if line == '':
                # p much copy-pasted from the parse_struct version
                if len(current_annotations) > 0:
                    raise ValueError(
                        f"Whitespace after annotations in a class - what do these annotations apply to?\n{current_annotations}\n" + 
                        "To apply annotations to the whole class, place them directly before the class definition."
                    )
                continue


            if line.startswith('@'):
                current_annotations.append(
                    self.parse_annotation(line)
                )
                # not using elifs off this bc of the semicolon check
                continue
            else:
                # can't check endswith(');') if there isn't a semicolon
                # also unconditionally removing the last char of a field line
                assert line.endswith(';'), 'get ur semicolons sorted out dickhead'
            
            if line.endswith(');'):
                # method
                method = self.parse_function(line, current_annotations)
                for param in method.params:
                    if param == "struct_ptr":
                        raise NameError("Class methods cannot have a parameter named 'struct_ptr'.")
                if not has_annotation(current_annotations, "Initializer"):
                    # fuckery to put struct_ptr at the _start_ of method.params
                    method.params = {"struct_ptr": CodegenType(typename = "void", is_pointer = True), **method.params}
                out.methods.append(
                    method
                )
                current_annotations = []
            else:
                raise ValueError("Class fields aren't supported, what the fuck do you think i am, a miracle worker?")
                field_type, field_name = self.to_codegen_type(line[:-1])
                # it's a field. probably.
                out.fields.append(
                    CodegenDataStructureField(
                        field_name,
                        field_type,
                        current_annotations
                    )
                )
                current_annotations = []
        
        # all that bollocks
        err_msg = out.validate()
        assert err_msg is None, err_msg

        return out
