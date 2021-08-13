#pragma once

#include <SDL2/SDL.h>

#include "native/c_codegen.h"

typedef struct {
    SDL_Cursor* arrow;
    SDL_Cursor* hand;
    SDL_Cursor* sizeAll;
    SDL_Cursor* sizeVertical;
    SDL_Cursor* sizeHorizontal;
} Cursors;

typedef struct {
    SDL_Window* win;
    SDL_Renderer* ren;
    SDLInitCode errorCode;

    Cursors* cursors;

    int frameCount;
} RenderWindow;