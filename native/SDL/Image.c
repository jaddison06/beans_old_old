#include <SDL2/SDL_image.h>

#include "Image.h"
#include "RenderWindow.h"

Image* InitImage(RenderWindow* rw, char* fname) {
    Image* out = malloc(sizeof(Image));

    SDL_Surface* imageSurface = IMG_Load(fname);

    out->imageTexture = SDL_CreateTextureFromSurface(rw->ren, imageSurface);

    out->width = imageSurface->w;
    out->height = imageSurface->h;

    SDL_FreeSurface(imageSurface);

    return out;
}

void DestroyImage(Image* image) {
    SDL_DestroyTexture(image->imageTexture);
    free(image);
}

int ImageGetWidth(Image* image) {
    return image->width;
}

int ImageGetHeight(Image* image) {
    return image->height;
}