#pragma once

#include <SDL2/SDL.h>

#include "native/c_codegen.h"

typedef struct {
    SDL_Window* win;
    SDL_Renderer* ren;
    SDLInitCode errorCode;

    int frameCount;
} RenderWindow;