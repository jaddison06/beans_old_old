#include <SDL2/SDL.h>

#include "native/c_codegen.h"

// todo: render text, images

typedef struct {
    SDL_Window* win;
    SDL_Renderer* ren;
    SDLInitCode errorCode;

    int frameCount;
} RenderWindow;

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
    //! always use SDL_GetCurrentDisplayMode to get window size.

    //SDL_GetWindowSize(rw->win, width, height);
    SDL_DisplayMode DM;
    SDL_GetCurrentDisplayMode(0, &DM);
    *width = DM.w;
    *height = DM.h;
    //printf("(%ix%i)\n", *width, *height);
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
    
    out->win = SDL_CreateWindow(title, 0, 0, 0, 0, SDL_WINDOW_FULLSCREEN);
    if (out->win == NULL) {
        return LogSDLError(out, SDLInitCode_CreateWindow_Fail);
    }

    out->ren = SDL_CreateRenderer(out->win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (out->ren == NULL) {
        return LogSDLError(out, SDLInitCode_CreateRenderer_Fail);
    }

    out->errorCode = SDLInitCode_Success;
    out->frameCount = 0;

    return out;
}

void DestroyRenderWindow(RenderWindow* rw) {
    SDL_DestroyRenderer(rw->ren);
    SDL_DestroyWindow(rw->win);
    SDL_Quit();
    free(rw);
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