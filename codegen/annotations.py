from codegen_types import *

def has_annotation(annotations: list[CodegenAnnotation], name: str) -> bool:
    for annotation in annotations:
        if annotation.name == name: return True
    
    return False

def get_annotation(annotations: list[CodegenAnnotation], name: str) -> CodegenAnnotation:
    return list(filter(lambda a: a.name == name, annotations))[0]