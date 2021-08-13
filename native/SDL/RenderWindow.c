#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

#include "RenderWindow.h"
#include "native/c_codegen.h"
#include "BeansFont.h"
#include "Image.h"

int RWGetFrameCount(RenderWindow* rw) {
    return rw->frameCount;
}

SDLInitCode RWGetErrorCode(RenderWindow* rw) {
    return rw->errorCode;
}

void RWGetSize(RenderWindow* rw, int* width, int* height) {
    // Not sure if this'll happen on real Linux, but on Windows with Xming,
    // the window doesn't go fullscreen immediately - it freezes briefly at
    // a resolution of 320x200. This doesn't block. So, if you call SDL_GetWindowSize
    // right after program start, it'll return weird values. The solution is to 
    //! always use SDL_GetDesktopDisplayMode to get window size.

    //SDL_GetWindowSize(rw->win, width, height);
    SDL_DisplayMode DM;
    // there's a subtle difference between GetCurrentDisplayMode and GetDesktopDisplayMode. according to the docs, i want
    // GetCurrentDisplayMode, but fsr it seems like GetDesktopDisplayMode works better
    // SDL_GetCurrentDisplayMode(0, &DM);
    SDL_GetDesktopDisplayMode(0, &DM);
    *width = DM.w;
    *height = DM.h;
    //printf("(%ix%i)\n", *width, *height);
}

Cursors* InitCursors() {
    Cursors* out = malloc(sizeof(Cursors));

    out->arrow           = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_ARROW);
    out->hand            = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_HAND);
    out->sizeAll        = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL);
    out->sizeVertical   = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZENS);
    out->sizeHorizontal = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZEWE);

    return out;
}

void DestroyCursors(Cursors* cursors) {
    SDL_FreeCursor(cursors->arrow);
    SDL_FreeCursor(cursors->hand);
    SDL_FreeCursor(cursors->sizeAll);
    SDL_FreeCursor(cursors->sizeVertical);
    SDL_FreeCursor(cursors->sizeHorizontal);

    free(cursors);
}

RenderWindow* LogSDLError(RenderWindow* win, int exitCode) {
    printf("SDL error: %s\n", SDL_GetError());
    if (win->win != NULL) {
        SDL_DestroyWindow(win->win);
    }
    if (win->ren != NULL) {
        SDL_DestroyRenderer(win->ren);
    }
    SDL_Quit();

    win->errorCode = exitCode;
    return win;
}

RenderWindow* InitRenderWindow(const char* title) {
    RenderWindow* out = malloc(sizeof(RenderWindow));

    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        return LogSDLError(out, SDLInitCode_InitVideo_Fail);
    }

    if (TTF_Init() != 0 ){
        return LogSDLError(out, SDLInitCode_TTF_Init_Fail);
    }
    
    out->win = SDL_CreateWindow(title, 0, 0, 0, 0, SDL_WINDOW_FULLSCREEN);
    if (out->win == NULL) {
        return LogSDLError(out, SDLInitCode_CreateWindow_Fail);
    }

    out->ren = SDL_CreateRenderer(out->win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (out->ren == NULL) {
        return LogSDLError(out, SDLInitCode_CreateRenderer_Fail);
    }

    out->cursors = InitCursors();

    SDL_SetRenderDrawBlendMode(out->ren, SDL_BLENDMODE_BLEND);

    out->errorCode = SDLInitCode_Success;
    out->frameCount = 0;

    return out;
}

void DestroyRenderWindow(RenderWindow* rw) {
    DestroyCursors(rw->cursors);
    SDL_DestroyRenderer(rw->ren);
    SDL_DestroyWindow(rw->win);
    TTF_Quit();
    SDL_Quit();
    free(rw);
}

void SetCursor(RenderWindow* rw, Cursor cursor) {
    switch (cursor) {
        case Cursor_Arrow:          return SDL_SetCursor(rw->cursors->arrow);
        case Cursor_Hand:           return SDL_SetCursor(rw->cursors->hand);
        case Cursor_SizeAll:        return SDL_SetCursor(rw->cursors->sizeAll);
        case Cursor_SizeVertical:   return SDL_SetCursor(rw->cursors->sizeVertical);
        case Cursor_SizeHorizontal: return SDL_SetCursor(rw->cursors->sizeHorizontal);
    }
}

void SetColour(RenderWindow* rw, int r, int g, int b, int a) {
    SDL_SetRenderDrawColor(rw->ren, r, g, b, a);
}

void Flush(RenderWindow* rw) {
    SDL_RenderPresent(rw->ren);
    SetColour(rw, 0, 0, 0, 255);
    SDL_RenderClear(rw->ren);

    rw->frameCount++;
}

void DrawPoint(RenderWindow* rw, int x, int y) {
    SDL_RenderDrawPoint(rw->ren, x, y);
}

void DrawLine(RenderWindow* rw, int x1, int y1, int x2, int y2) {
    SDL_RenderDrawLine(rw->ren, x1, y1, x2, y2);
}

void DrawRect(RenderWindow* rw, int x, int y, int w, int h) {
    SDL_Rect rect = {
        x: x,
        y: y,
        w: w,
        h: h
    };
    SDL_RenderDrawRect(rw->ren, &rect);
}

void FillRect(RenderWindow* rw, int x, int y, int w, int h) {
    SDL_Rect rect = {
        x: x,
        y: y,
        w: w,
        h: h
    };
    SDL_RenderFillRect(rw->ren, &rect);
}

SDL_Texture* GetTextTexture(RenderWindow* rw, TTF_Font* font, char* text, int r, int g, int b, int a, int* width, int* height) {
    SDL_Color col = {
        r: r,
        g: g,
        b: b,
        a: a
    };

    SDL_Surface* textSurface = TTF_RenderText_Solid(font, text, col);
    SDL_Texture* textTexture = SDL_CreateTextureFromSurface(rw->ren, textSurface);
    *width = textSurface->w;
    *height = textSurface->h;
    SDL_FreeSurface(textSurface);
    return textTexture;
}

void RenderTexture(RenderWindow* rw, SDL_Texture* texture, int x, int y, int width, int height) {
    SDL_Rect renderRect = {
        x: x,
        y: y,
        w: width,
        h: height
    };
    SDL_RenderCopy(rw->ren, texture, NULL, &renderRect);
}

void DrawText(RenderWindow* rw, BeansFont* font, char* text, int x, int y, int r, int g, int b, int a) {
    int width, height;
    SDL_Texture* textTexture = GetTextTexture(rw, font->font, text, r, g, b, a, &width, &height);
    RenderTexture(rw, textTexture, x, y, width, height);
    SDL_DestroyTexture(textTexture);
}

void DrawImage(RenderWindow* rw, Image* image, int x, int y, double scale) {
    RenderTexture(rw, image->imageTexture, x, y, image->width * scale, image->height * scale);
}