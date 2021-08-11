from paths import *

def codegen() -> str:
    # Files and directories that we don't want cloc to count.
    out = "\n".join([
        ".dart_tool",
        ".vscode",
        "build",
        "Makefile",
        DART_OUTPUT_PATH,
        C_OUTPUT_PATH
    ])

    return out