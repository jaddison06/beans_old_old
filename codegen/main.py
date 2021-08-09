import os
import os.path as path

from parse import *
from codegen_types import *
from paths import *

import c
import makefile
import dart

def all_with_extension(directory: str, ext: str) -> list[str]:
    out: list[str] = []
    for root, _, files in os.walk(directory):
        for file in files:
            if path.splitext(file)[-1] == ext:
                out.append(path.join(root, file))
    
    return out

def main():
    parsed_files: list[ParsedGenFile] = []
    for gen_file in all_with_extension("native", ".gen"):
        parsed_files.append(
            Parser(gen_file).parse()
        )
    
    with open(DART_OUTPUT_PATH, "wt") as fh:
        fh.write(dart    .codegen(parsed_files))
    with open(C_OUTPUT_PATH,    "wt") as fh:
        fh.write(c       .codegen(parsed_files))
    with open("Makefile",       "wt") as fh:
        fh.write(makefile.codegen(parsed_files))

    

if __name__ == '__main__': main()