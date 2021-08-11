.PHONY: codegen

all: codegen libraries

libraries: build/native/SDL/libRenderWindow.so build/native/SDL/libEvent.so

codegen:
	python codegen/main.py

run: libraries
	dart run

clean:
	rm -rf build
	rm -f native/c_codegen.h
	rm -f bin/dart_codegen.dart

cloc:
	cloc . --exclude-list=build/cloc_exclude_list.txt

build/native/SDL/libRenderWindow.so: native/SDL/RenderWindow.c
	mkdir -p build/native/SDL
	gcc -shared -o build/native/SDL/libRenderWindow.so -fPIC -I. native/SDL/RenderWindow.c -lSDL2

build/native/SDL/libEvent.so: native/SDL/Event.c
	mkdir -p build/native/SDL
	gcc -shared -o build/native/SDL/libEvent.so -fPIC -I. native/SDL/Event.c -lSDL2

