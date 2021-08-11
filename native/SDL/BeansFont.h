#pragma once
#include <SDL2/SDL_ttf.h>

typedef struct {
    char* name;
    int size;
    TTF_Font* font;
} BeansFont;