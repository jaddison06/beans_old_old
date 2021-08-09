.PHONY: codegen

all: codegen libraries

libraries:

codegen:
	python codegen/main.py

run: libraries
	dart run

clean:
	rm -rf build
	rm -f native/c_codegen.h
	rm -f bin/dart_codegen.dart

