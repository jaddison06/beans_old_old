from codegen_types import *

class TypeLookup:
    def __init__(self, files: list[ParsedGenFile]):
        self.enums: list[str] = []
        self.structs: list[str] = []
        self.classes: list[str] = []
        
        for file in files:
            for enum in file.enums:
                self.enums.append(enum.name)
            for struct in file.structs:
                self.structs.append(struct.name)
            for class_ in file.classes:
                self.classes.append(class_.name)
        
    def is_enum(self, typename: str) -> bool:
        return typename in self.enums
    def is_struct(self, typename: str) -> bool:
        return typename in self.structs
    def is_class(self, typename: str) -> bool:
        return typename in self.classes
    
    def exists(self, typename: str) -> bool:
        return self.is_enum(typename) or self.is_struct(typename) or self.is_class(typename)
