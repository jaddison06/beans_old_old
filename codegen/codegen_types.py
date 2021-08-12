from dataclasses import dataclass
from typing import Optional
import os.path as path

@dataclass
class CodegenAnnotation:
    name: str
    args: list[str]

    def __str__(self) -> str:
        return f"@{self.name}({', '.join(self.args)})"

@dataclass
class CodegenType:
    typename: str
    is_pointer: bool

    def c_type(self) -> str:
        out = self.typename

        if self.is_pointer: out += "*"

        return out

@dataclass
class CodegenFunction:
    name: str
    return_type: CodegenType
    params: dict[str, CodegenType]
    annotations: list[CodegenAnnotation]

    def signature_string(self) -> str:
        out = ""

        out += self.return_type.c_type()
        out += " "
        out += self.name
        out += "("
        for i, param_name in enumerate(self.params):
            param_type = self.params[param_name]
            out += param_type.c_type()
            out += " "
            out += param_name
            if i != len(self.params) - 1:
                out += ", "
        
        out += ")"

        return out

@dataclass
class CodegenDataStructureField:
    name: str
    type_: CodegenType
    annotations: list[CodegenAnnotation]

@dataclass
class CodegenEnumValue:
    name: str
    stringify_as: str

@dataclass
class CodegenEnum:
    name: str
    values: list[CodegenEnumValue]
    annotations: list[CodegenAnnotation]

@dataclass
class CodegenClass:
    name: str
    fields: list[CodegenDataStructureField]
    methods: list[CodegenFunction]
    annotations: list[CodegenAnnotation]

    def has_initializer_annotation(self, method: CodegenFunction) -> bool:
        for annotation in method.annotations:
            if annotation.name == "Initializer":
                return True
        return False

    def validate(self) -> Optional[str]:
        initializer: Optional[CodegenFunction] = None
        for method in self.methods:
            if self.has_initializer_annotation(method):
                initializer = method
                break
        
        if initializer is None:
            return f"The class {self.name} must have a method annotated as @Initializer."
        
        if not (
            initializer.return_type.typename == "void" and
            initializer.return_type.is_pointer):
            return f"The initializer for the class {self.name} must have a return type of void* ."

    
    def initializer(self) -> CodegenFunction:
        for method in self.methods:
            if self.has_initializer_annotation(method):
                return method
        
        raise ValueError("CodegenClass.initializer() was called but no initializer method was found.")

@dataclass
class ParsedGenFile:
    # eg native/some_subdir/something.gen
    name: str

    functions: list[CodegenFunction]
    enums: list[CodegenEnum]
    classes: list[CodegenClass]

    annotations: list[CodegenAnnotation]

    # returns "something"
    def id(self) -> str:
        return path.splitext(path.basename(self.name))[0]
    
    def name_no_ext(self) -> str:
        return path.splitext(self.name)[0]
    
    def libpath_no_ext(self) -> str:
        return path.dirname(self.name) + path.sep + self.libname()
    
    def libname(self) -> str:
        return f"lib{self.id()}"
