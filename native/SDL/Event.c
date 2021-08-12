#include <SDL2/SDL.h>

#include "native/c_codegen.h"

SDL_Event* CreateEvent() {
    return malloc(sizeof(SDL_Event));
}

void FreeEvent(SDL_Event* event) {
    free(event);
}

int Poll(SDL_Event* event) {
    SDL_PollEvent(event);
}

SDLEventType GetEventType(SDL_Event* event) {
    switch (event->type) {
        case SDL_QUIT: return SDLEventType_Quit;
        case SDL_APP_LOWMEMORY: return SDLEventType_LowMemory;
        case SDL_KEYDOWN: return SDLEventType_KeyDown;
        case SDL_KEYUP: return SDLEventType_KeyUp;
        case SDL_MOUSEMOTION: return SDLEventType_MouseMove;
        case SDL_MOUSEBUTTONDOWN: return SDLEventType_MouseDown;
        case SDL_MOUSEBUTTONUP: return SDLEventType_MouseUp;
        case SDL_MOUSEWHEEL: return SDLEventType_MouseScroll;
        case SDL_FINGERDOWN: return SDLEventType_FingerDown;
        case SDL_FINGERUP: return SDLEventType_FingerUp;
        case SDL_FINGERMOTION: return SDLEventType_FingerDrag;
        
        default: return SDLEventType_NotImplemented;
    }
}

void GetMouseMoveData(SDL_Event* event, int* x, int* y) {
    *x = event->motion.x;
    *y = event->motion.y;
}

MouseButton GetMousePressReleaseData(SDL_Event* event, int* x, int* y) {
    *x = event->button.x;
    *y = event->button.y;
    switch (event->button.button) {
        case SDL_BUTTON_LEFT:   return MouseButton_Left;
        case SDL_BUTTON_MIDDLE: return MouseButton_Middle;
        case SDL_BUTTON_RIGHT:  return MouseButton_Right;
        
        default:                return MouseButton_Unknown;
    }
}

KeyCode GetKeyPressReleaseData(SDL_Event* event) {
    switch (event->key.keysym.sym) {
        case SDLK_a: return KeyCode_A;
        case SDLK_b: return KeyCode_B;
        case SDLK_c: return KeyCode_C;
        case SDLK_d: return KeyCode_D;
        case SDLK_e: return KeyCode_E;
        case SDLK_f: return KeyCode_F;
        case SDLK_g: return KeyCode_G;
        case SDLK_h: return KeyCode_H;
        case SDLK_i: return KeyCode_I;
        case SDLK_j: return KeyCode_J;
        case SDLK_k: return KeyCode_K;
        case SDLK_l: return KeyCode_L;
        case SDLK_m: return KeyCode_M;
        case SDLK_n: return KeyCode_N;
        case SDLK_o: return KeyCode_O;
        case SDLK_p: return KeyCode_P;
        case SDLK_q: return KeyCode_Q;
        case SDLK_r: return KeyCode_R;
        case SDLK_s: return KeyCode_S;
        case SDLK_t: return KeyCode_T;
        case SDLK_u: return KeyCode_U;
        case SDLK_v: return KeyCode_V;
        case SDLK_w: return KeyCode_W;
        case SDLK_x: return KeyCode_X;
        case SDLK_y: return KeyCode_Y;
        case SDLK_z: return KeyCode_Z;

        case SDLK_1: return KeyCode_One;
        case SDLK_2: return KeyCode_Two;
        case SDLK_3: return KeyCode_Three;
        case SDLK_4: return KeyCode_Four;
        case SDLK_5: return KeyCode_Five;
        case SDLK_6: return KeyCode_Six;
        case SDLK_7: return KeyCode_Seven;
        case SDLK_8: return KeyCode_Eight;
        case SDLK_9: return KeyCode_Nine;
        case SDLK_0: return KeyCode_Zero;

        case SDLK_EXCLAIM: return KeyCode_Exclamation;
        case SDLK_QUESTION: return KeyCode_Question;
        case SDLK_QUOTEDBL: return KeyCode_DoubleQuote;
        case SDLK_QUOTE: return KeyCode_SingleQuote;
        // todo: pound?
        case SDLK_DOLLAR: return KeyCode_Dollar;
        case SDLK_PERCENT: return KeyCode_Percent;
        case SDLK_CARET: return KeyCode_Caret;
        case SDLK_AMPERSAND: return KeyCode_Ampersand;
        case SDLK_ASTERISK: return KeyCode_Asterisk;
        case SDLK_MINUS: return KeyCode_Hyphen;
        case SDLK_UNDERSCORE: return KeyCode_Underscore;
        case SDLK_EQUALS: return KeyCode_Equals;
        case SDLK_PLUS: return KeyCode_Plus;
        // todo: pipe
        case SDLK_SEMICOLON: return KeyCode_Semicolon;
        case SDLK_COLON: return KeyCode_Colon;
        case SDLK_AT: return KeyCode_At;
        // todo: tilde
        case SDLK_HASH: return KeyCode_Hash;
        case SDLK_BACKQUOTE: return KeyCode_Backtick;

        case SDLK_LEFTPAREN: return KeyCode_NormalBracketL;
        case SDLK_RIGHTPAREN: return KeyCode_NormalBracketR;
        case SDLK_LEFTBRACKET: return KeyCode_SquareBracketL;
        case SDLK_RIGHTBRACKET: return KeyCode_SquareBracketR;
        // todo: braces
        case SDLK_LESS: return KeyCode_SmallerThan;
        case SDLK_GREATER: return KeyCode_GreaterThan;

        case SDLK_RETURN: return KeyCode_Return;
        case SDLK_ESCAPE: return KeyCode_Escape;
        case SDLK_BACKSPACE: return KeyCode_Backspace;
        case SDLK_DELETE: return KeyCode_Delete;
        case SDLK_TAB: return KeyCode_Tab;
        case SDLK_SPACE: return KeyCode_Space;

        case SDLK_INSERT: return KeyCode_Insert;
        case SDLK_HOME: return KeyCode_Home;
        case SDLK_END: return KeyCode_End;
        case SDLK_PAGEUP: return KeyCode_PageUp;
        case SDLK_PAGEDOWN: return KeyCode_PageDown;

        case SDLK_RIGHT: return KeyCode_ArrowRight;
        case SDLK_LEFT: return KeyCode_ArrowLeft;
        case SDLK_DOWN: return KeyCode_ArrowDown;
        case SDLK_UP: return KeyCode_ArrowUp;

        case SDLK_KP_DIVIDE: return KeyCode_NumpadDivide;
        case SDLK_KP_MULTIPLY: return KeyCode_NumpadMultiply;
        case SDLK_KP_MINUS: return KeyCode_NumpadSubtract;
        case SDLK_KP_PLUS: return KeyCode_NumpadAdd;
        case SDLK_KP_EQUALS: return KeyCode_NumpadEquals;
        case SDLK_KP_ENTER: return KeyCode_NumpadEnter;
        case SDLK_KP_PERIOD: return KeyCode_NumpadDecimalPoint;
        
        case SDLK_KP_1: return KeyCode_NumpadOne;
        case SDLK_KP_2: return KeyCode_NumpadTwo;
        case SDLK_KP_3: return KeyCode_NumpadThree;
        case SDLK_KP_4: return KeyCode_NumpadFour;
        case SDLK_KP_5: return KeyCode_NumpadFive;
        case SDLK_KP_6: return KeyCode_NumpadSix;
        case SDLK_KP_7: return KeyCode_NumpadSeven;
        case SDLK_KP_8: return KeyCode_NumpadEight;
        case SDLK_KP_9: return KeyCode_NumpadNine;
        case SDLK_KP_0: return KeyCode_NumpadZero;

        case SDLK_F1: return KeyCode_Function_F1;
        case SDLK_F2: return KeyCode_Function_F2;
        case SDLK_F3: return KeyCode_Function_F3;
        case SDLK_F4: return KeyCode_Function_F4;
        case SDLK_F5: return KeyCode_Function_F5;
        case SDLK_F6: return KeyCode_Function_F6;
        case SDLK_F7: return KeyCode_Function_F7;
        case SDLK_F8: return KeyCode_Function_F8;
        case SDLK_F9: return KeyCode_Function_F9;
        case SDLK_F10: return KeyCode_Function_F10;
        case SDLK_F11: return KeyCode_Function_F11;
        case SDLK_F12: return KeyCode_Function_F12;

        case SDLK_LCTRL: return KeyCode_LControl;
        case SDLK_RCTRL: return KeyCode_RControl;
        case SDLK_LSHIFT: return KeyCode_LShift;
        case SDLK_RSHIFT: return KeyCode_RShift;
        case SDLK_LALT: return KeyCode_LAlt;
        case SDLK_RALT: return KeyCode_RAlt;

        case SDLK_AUDIONEXT: return KeyCode_AudioNext;
        case SDLK_AUDIOPREV: return KeyCode_AudioPrev;
        case SDLK_AUDIOSTOP: return KeyCode_AudioStop;
        case SDLK_AUDIOPLAY: return KeyCode_AudioPlay;
        
        default: return KeyCode_Unknown;
    }

}