#pragma once

#include <SDL2/SDL.h>

typedef struct {
    SDL_Texture* imageTexture;
    
    int width;
    int height;
} Image;