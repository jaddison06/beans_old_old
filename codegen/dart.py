from codegen_types import *
from typelookup import *
from banner import *
import os.path as path
from shared_library_extension import *
from typing import Callable
from annotations import *

NATIVE: dict[str, str] = {
    "void": "Void",
    "char": "Utf8",
    "int": "Int32",
    "double": "Double"
}

DART: dict[str, str] = {
    "void": "void",
    "char": "Utf8",
    "int": "int",
    "double": "double"
}

# omg globals! what the hell jaddison! you're a terrible programmer and i hope you eat shit!
lookup: TypeLookup

def get_typename(type_: CodegenType, typename_dict: dict[str, str]) -> str:
    assert type_.typename in typename_dict or lookup.exists(type_.typename), f"Cannot find type {type_.typename}"
    if type_.typename in typename_dict:
        codegen_typename = type_.typename
    elif lookup.is_enum(type_.typename):
        codegen_typename = "int"
    else:
        raise ValueError(f"Data structures like {type_.typename} aren't currently supported.")
    
    if type_.is_pointer:
        return f"Pointer<{NATIVE[codegen_typename]}>"
    else:
        return typename_dict[codegen_typename]

def func_sig_name(file: ParsedGenFile, func_name: str, native: bool) -> str:
    out = f"_{file.libname()}_func_{func_name}"

    if native: out += "_native"
    out += "_sig"

    return out

def method_sig_name(file: ParsedGenFile, class_: CodegenClass, method: CodegenFunction, native: bool) -> str:
    out = f"_{file.libname()}_class_{class_.name}_method_{method.name}"

    if native: out += "_native"
    out += "_sig"

    return out

def func_typedefs(funcs: list[CodegenFunction], getName: Callable[[CodegenFunction, bool], str]) -> str:
    out = ""

    for func in funcs:
        out += f"// {func.signature_string()}\n"
        out += f"typedef {getName(func, True)} = {get_typename(func.return_type, NATIVE)} Function("
        for i, param_type in enumerate(func.params.values()):
            out += get_typename(param_type, NATIVE)
            if i != len(func.params) - 1:
                out += ", "
        out += ");\n"

        out += f"typedef {getName(func, False)} = {get_typename(func.return_type, DART)} Function("
        for i, param_type in enumerate(func.params.values()):
            out += get_typename(param_type, DART)
            if i!= len(func.params) - 1:
                out += ", "
        out += ");\n\n"

    return out

def func_class_private_refs(funcs: list[CodegenFunction], getName: Callable[[CodegenFunction], str]) -> str:
    out = ""

    for func in funcs:
        out += f"    late {getName(func)} _{func.name};\n"
    out += "\n"

    return out

def param_list(func: CodegenFunction) -> str:
    out: str = ""

    for i, param_name in enumerate(func.params):
        param_type = func.params[param_name]
        dart_type = get_typename(param_type, DART)

        # THIS IS WHERE STUFF FOR ENUMS, STRUCTS, ETC WILL GO !!!
        if dart_type == "Pointer<Utf8>":
            dart_type = "String"
        elif lookup.is_enum(param_type.typename):
            dart_type = param_type.typename
        
        out += f"{dart_type} {param_name}"
        if i != len(func.params) - 1:
            out += ", "

    out += ") {\n"

    return out


def func_class_get_library(file: ParsedGenFile) -> str:
    out = ""

    out += f"        final lib = DynamicLibrary.open('build{path.sep}"
    # in the Dart string, if we're on Windows, we want to put "build\\whatever", or the slash will get interpreted
    # by Dart as an escape character
    if path.sep == "\\":
        out += "\\"
    out += file.libpath_no_ext().replace("\\", "\\\\")
    
    out += f"{shared_library_extension()}');\n\n"

    return out

def func_class_init_refs(funcs: list[CodegenFunction], getName: Callable[[CodegenFunction, bool], str]) -> str:
    out = ""

    for func in funcs:
        out += f"        _{func.name} = lib.lookupFunction<{getName(func, True)}, {getName(func, False)}>('{func.name}');\n"

    return out

def func_params(func: CodegenFunction) -> str:
    out = ""

    for i, param_name in enumerate(func.params):
        param_type = func.params[param_name]
        param_typename = get_typename(param_type, DART)
        if param_typename == "Pointer<Utf8>":
            out += f"{param_name}.toNativeUtf8()"
        elif lookup.is_enum(param_type.typename):
            out += f"{param_type.typename}ToInt({param_name})"
        else:
            out += param_name
        
        if i != len(func.params) - 1:
            out += ", "

    return out

def funcs(file: ParsedGenFile) -> str:
    out: str = ""

    out += banner("function signature typedefs")
    # for func in file.functions:
    #     out += f"// {func.signature_string()}\n"
    #     out += f"typedef {func_sig_name(file, func.name, True)} = {get_typename(func.return_type, NATIVE)} Function("
    #     for i, param_type in enumerate(func.params.values()):
    #         out += get_typename(param_type, NATIVE)
    #         if i != len(func.params) - 1:
    #             out += ", "
    #     out += ");\n"

    #     out += f"typedef {func_sig_name(file, func.name, False)} = {get_typename(func.return_type, DART)} Function("
    #     for i, param_type in enumerate(func.params.values()):
    #         out += get_typename(param_type, DART)
    #         if i!= len(func.params) - 1:
    #             out += ", "
    #     out += ");\n\n"
    out += func_typedefs(file.functions, lambda func, is_native: func_sig_name(file, func.name, is_native))
    
    out += banner(file.libname())

    out += f"class {file.libname()} {{\n\n"
    out += func_class_private_refs(file.functions, lambda func: func_sig_name(file, func.name, False))
    
    out += f"    {file.libname()}() {{\n"
   
    out += func_class_get_library(file)

    # for func in file.functions:
    #     out += f"        _{func.name} = lib.lookupFunction<{func_sig_name(file, func.name, True)}, {func_sig_name(file, func.name, False)}>('{func.name}');\n"
    out += func_class_init_refs(file.functions, lambda func, is_native: func_sig_name(file, func.name, is_native))
    out += "    }\n\n"

    for func in file.functions:
        out += f"    {get_typename(func.return_type, DART)} {func.name}("
        # for i, param_name in enumerate(func.params):
        #     param_type = func.params[param_name]
        #     dart_type = get_typename(param_type, DART)

        #     # THIS IS WHERE STUFF FOR ENUMS, STRUCTS, ETC WILL GO !!!
        #     if dart_type == "Pointer<Utf8>":
        #         dart_type = "String"
        #     elif lookup.is_enum(param_type.typename):
        #         dart_type = param_type.typename
            
        #     out += f"{dart_type} {param_name}"
        #     if i != len(func.params) - 1:
        #         out += ", "
            
        #out += ") {\n"

        out += param_list(func)

        out += f"        return _{func.name}("
        out += func_params(func)
        
        out += ");\n"
        out += "    }\n\n"
    
    out += "}\n\n\n"
    
    return out



def enums(file: ParsedGenFile) -> str:
    out = ""

    out += banner("enums")
    for enum in file.enums:
        out += f"enum {enum.name} {{\n"
        for value in enum.values:
            out += f"    {value.name},\n"
        out += "}\n\n"
        out += f"{enum.name} {enum.name}FromInt(int val) => {enum.name}.values[val];\n"
        out += f"int {enum.name}ToInt({enum.name} val) => {enum.name}.values.indexOf(val);\n\n"
        out += f"String {enum.name}ToString({enum.name} val) {{\n"
        out += "    switch (val) {\n"
        for value in enum.values:
            out += f"        case {enum.name}.{value.name}: {{ return '{value.stringify_as}'; }}\n"
        out += "    }\n"
        out += "}\n\n"

    return out

def structs(file: ParsedGenFile) -> str: return ""

def classes(file: ParsedGenFile) -> str:
    out: str = ""

    out += banner("func sig typedefs for classes")
    for class_ in file.classes:
        out += banner(class_.name)
        out += func_typedefs(class_.methods, lambda method, is_native: method_sig_name(file, class_, method, is_native))
    
    out += banner("class implementations")
    for class_ in file.classes:
        out += f"class {class_.name} {{\n"
        out +=  "    Pointer<Void> structPointer = Pointer.fromAddress(0);\n\n"
        out +=  "    void _validatePointer(String methodName) {\n"
        out +=  "        if (structPointer.address == 0) {\n"
        out += f"            throw Exception('{class_.name}.$methodName was called, but structPointer is a nullptr.');\n"
        out +=  "        }\n"
        out +=  "    }\n\n"

        out += func_class_private_refs(class_.methods, lambda method: method_sig_name(file, class_, method, False))

        initializer = class_.initializer()
        out += f"    {class_.name}("
        out += param_list(initializer)
        out += func_class_get_library(file)
        out += func_class_init_refs(class_.methods, lambda method, is_native: method_sig_name(file, class_, method, is_native))

        out += f"\n        structPointer = _{initializer.name}("
        out += func_params(initializer)
        out += ");\n"
        out += "    }\n\n"

        for method in class_.methods:
            if has_annotation(method.annotations, "Initializer"): continue
            
            method_show_name = method.name
            if has_annotation(method.annotations, "Show"):
                method_show_name = get_annotation(method.annotations, "Show").args[0]
            
            out += f"    {get_typename(method.return_type, DART)} {method_show_name}("
            # hopefully it's not mutable !!!!!
            del method.params["struct_ptr"]
            out += param_list(method)
            out += f"        _validatePointer('{method.name}');\n"
            out += f"        return _{method.name}(structPointer"
            if len(method.params) > 0:
                out += ", "
            out += func_params(method)
            out += ");\n"
            out += "    }\n\n"
        
        out += "}\n\n"




    return out

# todo:
#   - structs are cancelled so we don't need to worry about them
#   - classes
#   - printf does not fuck?????????
#   - start testing libe131

def codegen(files: list[ParsedGenFile]) -> str:
    out = ""
    out += \
"""import 'dart:ffi';
import 'package:ffi/ffi.dart';


"""

    global lookup
    lookup = TypeLookup(files)

    for file in files:
        out += banner(f"file: {file.name}")
        out += funcs(file)
        out += enums(file)
        out += structs(file)
        out += classes(file)

    return out