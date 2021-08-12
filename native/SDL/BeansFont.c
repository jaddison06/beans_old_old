#include <SDL2/SDL_ttf.h>
#include "native/c_codegen.h"
#include "BeansFont.h"

void PrintFont(BeansFont* bf) {
    printf("BeansFont '%s' @ %p, size %i, TTF @ %p\n", bf->name, bf, bf->size, bf->font);
}

BeansFont* InitFont(const char* name, int size) {
    BeansFont* out = malloc(sizeof(BeansFont));

    out->size = size;

    // i don't trust Dart not to GC the name, so we'll make a copy
    out->name = malloc(strlen(name) + 1);
    strcpy(out->name, name);

    out->font = TTF_OpenFont(name, size);

    //PrintFont(out);

    return out;
}

void DestroyFont(BeansFont* bf) {
    TTF_CloseFont(bf->font);
    free(bf->name);
    free(bf);
}

void GetTextSize(BeansFont* bf, char* text, int* width, int* height) {
    TTF_SizeText(bf->font, text, width, height);
}

int GetTextWidth(BeansFont* bf, char* text) {
    int width;
    GetTextSize(bf, text, &width, NULL);
    return width;
}

int GetTextHeight(BeansFont* bf, char* text) {
    int height;
    GetTextSize(bf, text, NULL, &height);
    return height;
}

char* BFGetName(BeansFont* bf) {
    return bf->name;
}

int BFGetSize(BeansFont* bf) {
    return bf->size;
}