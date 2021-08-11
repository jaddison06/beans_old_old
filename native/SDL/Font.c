#include <SDL2/SDL_ttf.h>
#include "native/c_codegen.h"
#include "BeansFont.h"

BeansFont* InitFont(const char* name, int size) {
    BeansFont* out = malloc(sizeof(BeansFont));

    out->size = size;

    // i don't trust Dart not to GC the name, so we'll make a copy
    out->name = malloc(strlen(name) + 1);
    strcpy(out->name, name);

    out->font = TTF_OpenFont(name, size);

    /*printf(
        "Initialized BeansFont @ %p, name %s, size %i, ttf @ %p, pname %s, psize %i\n",
        out, out->name, out->size, out->font, name, size
    );*/

    return out;
}

void DestroyFont(BeansFont* bf) {
    puts("DestroyFont");
    TTF_CloseFont(bf->font);
    free(bf->name);
    free(bf);
}

char* BFGetName(BeansFont* bf) {
    return bf->name;
}

int BFGetSize(BeansFont* bf) {
    return bf->size;
}