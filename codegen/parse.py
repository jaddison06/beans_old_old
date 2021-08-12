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
            [], [], [], []
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
            
            
            if line.startswith("enum"):
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

    #* ALL PARSE FUNCTIONS NEED TO MAKE SURE THEY CAN ACCEPT LINES WITH A COMMENT AT THE END:
    # void some_code() // this code does something!!

    def normalize(self, line: str, ensure_newline: bool = False) -> str:
        if '//' in line:
            line = line.split('//')[0].strip()
        if (not line.endswith('\n')) and ensure_newline:
            line += '\n'
        elif line.endswith('\n') and (not ensure_newline):
            line = line[:-1]
        
        return line

    def parse_annotation(self, annotation: str) -> CodegenAnnotation:
        assert "(" in annotation, "Annotations must end with parentheses, even if they have no arguments."
        
        annotation = self.normalize(annotation, True)

        name, args_raw = annotation[1:].split("(")
        args: list[str] = []
        if not args_raw == ")\n":
            args = strip_all(
                args_raw[:-2].split(",")
            )
        return CodegenAnnotation(
            name,
            args
        )

    
    def parse_function(self, function: str, annotations: list[CodegenAnnotation]) -> CodegenFunction:
        function = self.normalize(function, True)

        name_and_return_type, params_raw = function.split("(")

        return_type, name = self.to_codegen_type(name_and_return_type)
        
        params: dict[str, CodegenType] = {}
        if not params_raw == ")\n":
            for param in params_raw[:-2].split(","):
                param_type, param_name = self.to_codegen_type(param.strip())
                params[param_name] = param_type
        
        return CodegenFunction(
            name,
            return_type,
            params,
            annotations
        )

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
                if len(current_annotations) > 0:
                    raise ValueError(
                        f"Whitespace after annotations in a class - what do these annotations apply to?\n{current_annotations}\n" + 
                        "To apply annotations to the whole class, place them directly before the class definition."
                    )
                continue
                
            line = self.normalize(line)


            if line.startswith('@'):
                current_annotations.append(
                    self.parse_annotation(line)
                )
                # not using elifs off this bc of the semicolon check
                continue
            
            if line.endswith(')'):
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
                raise ValueError("Class fields aren't supported yet, what the fuck do you think i am, a miracle worker?")
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
