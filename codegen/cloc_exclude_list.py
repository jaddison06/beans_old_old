from paths import *

def codegen() -> str:
    # Files and directories that we don't want cloc to count.
    out = "\n".join([
        ".dart_tool",
        ".vscode",
        "build",
        DART_OUTPUT_PATH,
        C_OUTPUT_PATH,
        "Makefile",
        CLOC_EXCLUDE_LIST_PATH
    ])

    return out