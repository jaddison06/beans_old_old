.PHONY: codegen

all: codegen libraries

libraries: build/native/SDL/libRenderWindow.so build/native/SDL/libBeansFont.so build/native/SDL/libImage.so build/native/SDL/libEvent.so

codegen:
	python codegen/main.py

run: all
	dart run

clean:
	rm -rf build
	rm -f native/c_codegen.h
	rm -f bin/dart_codegen.dart

cloc:
	cloc . --exclude-list=.cloc_exclude_list.txt

build/native/SDL/libRenderWindow.so: native/SDL/RenderWindow.c
	mkdir -p build/native/SDL
	gcc -shared -o build/native/SDL/libRenderWindow.so -fPIC -I. native/SDL/RenderWindow.c -lSDL2 -lSDL2_ttf

build/native/SDL/libBeansFont.so: native/SDL/BeansFont.c
	mkdir -p build/native/SDL
	gcc -shared -o build/native/SDL/libBeansFont.so -fPIC -I. native/SDL/BeansFont.c -lSDL2_ttf

build/native/SDL/libImage.so: native/SDL/Image.c
	mkdir -p build/native/SDL
	gcc -shared -o build/native/SDL/libImage.so -fPIC -I. native/SDL/Image.c -lSDL2 -lSDL2_image

build/native/SDL/libEvent.so: native/SDL/Event.c
	mkdir -p build/native/SDL
	gcc -shared -o build/native/SDL/libEvent.so -fPIC -I. native/SDL/Event.c -lSDL2

