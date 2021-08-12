// for native types & basic FFI functionality
import 'dart:ffi';
// for string utils
import 'package:ffi/ffi.dart';
// for @mustCallSuper
import 'package:meta/meta.dart';

// ----------FILE: NATIVE/SDL/RENDERWINDOW.GEN----------

// ----------ENUMS----------

enum SDLInitCode {
    Success,
    InitVideo_Fail,
    TTF_Init_Fail,
    CreateWindow_Fail,
    CreateRenderer_Fail,
}

SDLInitCode SDLInitCodeFromInt(int val) => SDLInitCode.values[val];
int SDLInitCodeToInt(SDLInitCode val) => SDLInitCode.values.indexOf(val);

String SDLInitCodeToString(SDLInitCode val) {
    switch (val) {
        case SDLInitCode.Success: { return 'Success'; }
        case SDLInitCode.InitVideo_Fail: { return 'SDL_InitVideo() failed'; }
        case SDLInitCode.TTF_Init_Fail: { return 'TTF_Init() failed'; }
        case SDLInitCode.CreateWindow_Fail: { return 'SDL_CreateWindow() failed'; }
        case SDLInitCode.CreateRenderer_Fail: { return 'SDL_CreateRenderer() failed'; }
    }
}

// ----------FUNC SIG TYPEDEFS FOR CLASSES----------

// ----------RENDERWINDOW----------

// void* InitRenderWindow(char* title)
typedef _libRenderWindow_class_RenderWindow_method_InitRenderWindow_native_sig = Pointer<Void> Function(Pointer<Utf8>);
typedef _libRenderWindow_class_RenderWindow_method_InitRenderWindow_sig = Pointer<Void> Function(Pointer<Utf8>);

// void DestroyRenderWindow(void* struct_ptr)
typedef _libRenderWindow_class_RenderWindow_method_DestroyRenderWindow_native_sig = Void Function(Pointer<Void>);
typedef _libRenderWindow_class_RenderWindow_method_DestroyRenderWindow_sig = void Function(Pointer<Void>);

// SDLInitCode RWGetErrorCode(void* struct_ptr)
typedef _libRenderWindow_class_RenderWindow_method_RWGetErrorCode_native_sig = Int32 Function(Pointer<Void>);
typedef _libRenderWindow_class_RenderWindow_method_RWGetErrorCode_sig = int Function(Pointer<Void>);

// int RWGetFrameCount(void* struct_ptr)
typedef _libRenderWindow_class_RenderWindow_method_RWGetFrameCount_native_sig = Int32 Function(Pointer<Void>);
typedef _libRenderWindow_class_RenderWindow_method_RWGetFrameCount_sig = int Function(Pointer<Void>);

// void RWGetSize(void* struct_ptr, int* width, int* height)
typedef _libRenderWindow_class_RenderWindow_method_RWGetSize_native_sig = Void Function(Pointer<Void>, Pointer<Int32>, Pointer<Int32>);
typedef _libRenderWindow_class_RenderWindow_method_RWGetSize_sig = void Function(Pointer<Void>, Pointer<Int32>, Pointer<Int32>);

// void Flush(void* struct_ptr)
typedef _libRenderWindow_class_RenderWindow_method_Flush_native_sig = Void Function(Pointer<Void>);
typedef _libRenderWindow_class_RenderWindow_method_Flush_sig = void Function(Pointer<Void>);

// void SetColour(void* struct_ptr, int r, int g, int b, int a)
typedef _libRenderWindow_class_RenderWindow_method_SetColour_native_sig = Void Function(Pointer<Void>, Int32, Int32, Int32, Int32);
typedef _libRenderWindow_class_RenderWindow_method_SetColour_sig = void Function(Pointer<Void>, int, int, int, int);

// void DrawPoint(void* struct_ptr, int x, int y)
typedef _libRenderWindow_class_RenderWindow_method_DrawPoint_native_sig = Void Function(Pointer<Void>, Int32, Int32);
typedef _libRenderWindow_class_RenderWindow_method_DrawPoint_sig = void Function(Pointer<Void>, int, int);

// void DrawLine(void* struct_ptr, int x1, int y1, int x2, int y2)
typedef _libRenderWindow_class_RenderWindow_method_DrawLine_native_sig = Void Function(Pointer<Void>, Int32, Int32, Int32, Int32);
typedef _libRenderWindow_class_RenderWindow_method_DrawLine_sig = void Function(Pointer<Void>, int, int, int, int);

// void DrawRect(void* struct_ptr, int x, int y, int w, int h)
typedef _libRenderWindow_class_RenderWindow_method_DrawRect_native_sig = Void Function(Pointer<Void>, Int32, Int32, Int32, Int32);
typedef _libRenderWindow_class_RenderWindow_method_DrawRect_sig = void Function(Pointer<Void>, int, int, int, int);

// void FillRect(void* struct_ptr, int x, int y, int w, int h)
typedef _libRenderWindow_class_RenderWindow_method_FillRect_native_sig = Void Function(Pointer<Void>, Int32, Int32, Int32, Int32);
typedef _libRenderWindow_class_RenderWindow_method_FillRect_sig = void Function(Pointer<Void>, int, int, int, int);

// void DrawText(void* struct_ptr, BeansFont* font, char* text, int x, int y, int r, int g, int b, int a)
typedef _libRenderWindow_class_RenderWindow_method_DrawText_native_sig = Void Function(Pointer<Void>, Pointer<Void>, Pointer<Utf8>, Int32, Int32, Int32, Int32, Int32, Int32);
typedef _libRenderWindow_class_RenderWindow_method_DrawText_sig = void Function(Pointer<Void>, Pointer<Void>, Pointer<Utf8>, int, int, int, int, int, int);

// ----------CLASS IMPLEMENTATIONS----------

class RenderWindow {
    Pointer<Void> structPointer = nullptr;

    void _validatePointer(String methodName) {
        if (structPointer.address == 0) {
            throw Exception('RenderWindow.$methodName was called, but structPointer is a nullptr.');
        }
    }

    static _libRenderWindow_class_RenderWindow_method_InitRenderWindow_sig? _InitRenderWindow;
    static _libRenderWindow_class_RenderWindow_method_DestroyRenderWindow_sig? _DestroyRenderWindow;
    static _libRenderWindow_class_RenderWindow_method_RWGetErrorCode_sig? _RWGetErrorCode;
    static _libRenderWindow_class_RenderWindow_method_RWGetFrameCount_sig? _RWGetFrameCount;
    static _libRenderWindow_class_RenderWindow_method_RWGetSize_sig? _RWGetSize;
    static _libRenderWindow_class_RenderWindow_method_Flush_sig? _Flush;
    static _libRenderWindow_class_RenderWindow_method_SetColour_sig? _SetColour;
    static _libRenderWindow_class_RenderWindow_method_DrawPoint_sig? _DrawPoint;
    static _libRenderWindow_class_RenderWindow_method_DrawLine_sig? _DrawLine;
    static _libRenderWindow_class_RenderWindow_method_DrawRect_sig? _DrawRect;
    static _libRenderWindow_class_RenderWindow_method_FillRect_sig? _FillRect;
    static _libRenderWindow_class_RenderWindow_method_DrawText_sig? _DrawText;

    void _initRefs() {
        if (
            _InitRenderWindow == null ||
            _DestroyRenderWindow == null ||
            _RWGetErrorCode == null ||
            _RWGetFrameCount == null ||
            _RWGetSize == null ||
            _Flush == null ||
            _SetColour == null ||
            _DrawPoint == null ||
            _DrawLine == null ||
            _DrawRect == null ||
            _FillRect == null ||
            _DrawText == null
        ) {
            final lib = DynamicLibrary.open('build/native/SDL/libRenderWindow.so');

            _InitRenderWindow = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_InitRenderWindow_native_sig, _libRenderWindow_class_RenderWindow_method_InitRenderWindow_sig>('InitRenderWindow');
            _DestroyRenderWindow = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_DestroyRenderWindow_native_sig, _libRenderWindow_class_RenderWindow_method_DestroyRenderWindow_sig>('DestroyRenderWindow');
            _RWGetErrorCode = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_RWGetErrorCode_native_sig, _libRenderWindow_class_RenderWindow_method_RWGetErrorCode_sig>('RWGetErrorCode');
            _RWGetFrameCount = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_RWGetFrameCount_native_sig, _libRenderWindow_class_RenderWindow_method_RWGetFrameCount_sig>('RWGetFrameCount');
            _RWGetSize = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_RWGetSize_native_sig, _libRenderWindow_class_RenderWindow_method_RWGetSize_sig>('RWGetSize');
            _Flush = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_Flush_native_sig, _libRenderWindow_class_RenderWindow_method_Flush_sig>('Flush');
            _SetColour = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_SetColour_native_sig, _libRenderWindow_class_RenderWindow_method_SetColour_sig>('SetColour');
            _DrawPoint = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_DrawPoint_native_sig, _libRenderWindow_class_RenderWindow_method_DrawPoint_sig>('DrawPoint');
            _DrawLine = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_DrawLine_native_sig, _libRenderWindow_class_RenderWindow_method_DrawLine_sig>('DrawLine');
            _DrawRect = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_DrawRect_native_sig, _libRenderWindow_class_RenderWindow_method_DrawRect_sig>('DrawRect');
            _FillRect = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_FillRect_native_sig, _libRenderWindow_class_RenderWindow_method_FillRect_sig>('FillRect');
            _DrawText = lib.lookupFunction<_libRenderWindow_class_RenderWindow_method_DrawText_native_sig, _libRenderWindow_class_RenderWindow_method_DrawText_sig>('DrawText');
        }
    }

    RenderWindow(String title) {
        _initRefs();
        structPointer = _InitRenderWindow!(title.toNativeUtf8());
    }

    RenderWindow.fromPointer(Pointer<Void> ptr) {
        _initRefs();
        structPointer = ptr;
    }

    @mustCallSuper
    void Destroy() {
        _validatePointer('Destroy');
        final out = _DestroyRenderWindow!(structPointer);

        // this method invalidates the pointer, probably by freeing memory
        structPointer = Pointer.fromAddress(0);

        return out;
    }

    SDLInitCode get errorCode {
        _validatePointer('errorCode');
        return SDLInitCodeFromInt(_RWGetErrorCode!(structPointer));
    }

    int get frameCount {
        _validatePointer('frameCount');
        return _RWGetFrameCount!(structPointer);
    }

    void GetSize(Pointer<Int32> width, Pointer<Int32> height) {
        _validatePointer('GetSize');
        return _RWGetSize!(structPointer, width, height);
    }

    void Flush() {
        _validatePointer('Flush');
        return _Flush!(structPointer);
    }

    void SetColour(int r, int g, int b, int a) {
        _validatePointer('SetColour');
        return _SetColour!(structPointer, r, g, b, a);
    }

    void DrawPoint(int x, int y) {
        _validatePointer('DrawPoint');
        return _DrawPoint!(structPointer, x, y);
    }

    void DrawLine(int x1, int y1, int x2, int y2) {
        _validatePointer('DrawLine');
        return _DrawLine!(structPointer, x1, y1, x2, y2);
    }

    void DrawRect(int x, int y, int w, int h) {
        _validatePointer('DrawRect');
        return _DrawRect!(structPointer, x, y, w, h);
    }

    void FillRect(int x, int y, int w, int h) {
        _validatePointer('FillRect');
        return _FillRect!(structPointer, x, y, w, h);
    }

    void cDrawText(BeansFont font, String text, int x, int y, int r, int g, int b, int a) {
        _validatePointer('cDrawText');
        return _DrawText!(structPointer, font.structPointer, text.toNativeUtf8(), x, y, r, g, b, a);
    }

}

// ----------FILE: NATIVE/SDL/BEANSFONT.GEN----------

// ----------FUNC SIG TYPEDEFS FOR CLASSES----------

// ----------BEANSFONT----------

// void* InitFont(char* name, int size)
typedef _libBeansFont_class_BeansFont_method_InitFont_native_sig = Pointer<Void> Function(Pointer<Utf8>, Int32);
typedef _libBeansFont_class_BeansFont_method_InitFont_sig = Pointer<Void> Function(Pointer<Utf8>, int);

// void DestroyFont(void* struct_ptr)
typedef _libBeansFont_class_BeansFont_method_DestroyFont_native_sig = Void Function(Pointer<Void>);
typedef _libBeansFont_class_BeansFont_method_DestroyFont_sig = void Function(Pointer<Void>);

// void GetTextSize(void* struct_ptr, char* text, int* width, int* height)
typedef _libBeansFont_class_BeansFont_method_GetTextSize_native_sig = Void Function(Pointer<Void>, Pointer<Utf8>, Pointer<Int32>, Pointer<Int32>);
typedef _libBeansFont_class_BeansFont_method_GetTextSize_sig = void Function(Pointer<Void>, Pointer<Utf8>, Pointer<Int32>, Pointer<Int32>);

// int GetTextWidth(void* struct_ptr, char* text)
typedef _libBeansFont_class_BeansFont_method_GetTextWidth_native_sig = Int32 Function(Pointer<Void>, Pointer<Utf8>);
typedef _libBeansFont_class_BeansFont_method_GetTextWidth_sig = int Function(Pointer<Void>, Pointer<Utf8>);

// int GetTextHeight(void* struct_ptr, char* text)
typedef _libBeansFont_class_BeansFont_method_GetTextHeight_native_sig = Int32 Function(Pointer<Void>, Pointer<Utf8>);
typedef _libBeansFont_class_BeansFont_method_GetTextHeight_sig = int Function(Pointer<Void>, Pointer<Utf8>);

// char* BFGetName(void* struct_ptr)
typedef _libBeansFont_class_BeansFont_method_BFGetName_native_sig = Pointer<Utf8> Function(Pointer<Void>);
typedef _libBeansFont_class_BeansFont_method_BFGetName_sig = Pointer<Utf8> Function(Pointer<Void>);

// int BFGetSize(void* struct_ptr)
typedef _libBeansFont_class_BeansFont_method_BFGetSize_native_sig = Int32 Function(Pointer<Void>);
typedef _libBeansFont_class_BeansFont_method_BFGetSize_sig = int Function(Pointer<Void>);

// ----------CLASS IMPLEMENTATIONS----------

class BeansFont {
    Pointer<Void> structPointer = nullptr;

    void _validatePointer(String methodName) {
        if (structPointer.address == 0) {
            throw Exception('BeansFont.$methodName was called, but structPointer is a nullptr.');
        }
    }

    static _libBeansFont_class_BeansFont_method_InitFont_sig? _InitFont;
    static _libBeansFont_class_BeansFont_method_DestroyFont_sig? _DestroyFont;
    static _libBeansFont_class_BeansFont_method_GetTextSize_sig? _GetTextSize;
    static _libBeansFont_class_BeansFont_method_GetTextWidth_sig? _GetTextWidth;
    static _libBeansFont_class_BeansFont_method_GetTextHeight_sig? _GetTextHeight;
    static _libBeansFont_class_BeansFont_method_BFGetName_sig? _BFGetName;
    static _libBeansFont_class_BeansFont_method_BFGetSize_sig? _BFGetSize;

    void _initRefs() {
        if (
            _InitFont == null ||
            _DestroyFont == null ||
            _GetTextSize == null ||
            _GetTextWidth == null ||
            _GetTextHeight == null ||
            _BFGetName == null ||
            _BFGetSize == null
        ) {
            final lib = DynamicLibrary.open('build/native/SDL/libBeansFont.so');

            _InitFont = lib.lookupFunction<_libBeansFont_class_BeansFont_method_InitFont_native_sig, _libBeansFont_class_BeansFont_method_InitFont_sig>('InitFont');
            _DestroyFont = lib.lookupFunction<_libBeansFont_class_BeansFont_method_DestroyFont_native_sig, _libBeansFont_class_BeansFont_method_DestroyFont_sig>('DestroyFont');
            _GetTextSize = lib.lookupFunction<_libBeansFont_class_BeansFont_method_GetTextSize_native_sig, _libBeansFont_class_BeansFont_method_GetTextSize_sig>('GetTextSize');
            _GetTextWidth = lib.lookupFunction<_libBeansFont_class_BeansFont_method_GetTextWidth_native_sig, _libBeansFont_class_BeansFont_method_GetTextWidth_sig>('GetTextWidth');
            _GetTextHeight = lib.lookupFunction<_libBeansFont_class_BeansFont_method_GetTextHeight_native_sig, _libBeansFont_class_BeansFont_method_GetTextHeight_sig>('GetTextHeight');
            _BFGetName = lib.lookupFunction<_libBeansFont_class_BeansFont_method_BFGetName_native_sig, _libBeansFont_class_BeansFont_method_BFGetName_sig>('BFGetName');
            _BFGetSize = lib.lookupFunction<_libBeansFont_class_BeansFont_method_BFGetSize_native_sig, _libBeansFont_class_BeansFont_method_BFGetSize_sig>('BFGetSize');
        }
    }

    BeansFont(String name, int size) {
        _initRefs();
        structPointer = _InitFont!(name.toNativeUtf8(), size);
    }

    BeansFont.fromPointer(Pointer<Void> ptr) {
        _initRefs();
        structPointer = ptr;
    }

    @mustCallSuper
    void Destroy() {
        _validatePointer('Destroy');
        final out = _DestroyFont!(structPointer);

        // this method invalidates the pointer, probably by freeing memory
        structPointer = Pointer.fromAddress(0);

        return out;
    }

    void GetTextSize(String text, Pointer<Int32> width, Pointer<Int32> height) {
        _validatePointer('GetTextSize');
        return _GetTextSize!(structPointer, text.toNativeUtf8(), width, height);
    }

    int GetTextWidth(String text) {
        _validatePointer('GetTextWidth');
        return _GetTextWidth!(structPointer, text.toNativeUtf8());
    }

    int GetTextHeight(String text) {
        _validatePointer('GetTextHeight');
        return _GetTextHeight!(structPointer, text.toNativeUtf8());
    }

    String get name {
        _validatePointer('name');
        return (_BFGetName!(structPointer)).toDartString();
    }

    int get size {
        _validatePointer('size');
        return _BFGetSize!(structPointer);
    }

}

// ----------FILE: NATIVE/SDL/EVENT.GEN----------

// ----------ENUMS----------

enum SDLEventType {
    Quit,
    LowMemory,
    KeyDown,
    KeyUp,
    MouseMove,
    MouseDown,
    MouseUp,
    MouseScroll,
    FingerDown,
    FingerUp,
    FingerDrag,
    NotImplemented,
}

SDLEventType SDLEventTypeFromInt(int val) => SDLEventType.values[val];
int SDLEventTypeToInt(SDLEventType val) => SDLEventType.values.indexOf(val);

String SDLEventTypeToString(SDLEventType val) {
    switch (val) {
        case SDLEventType.Quit: { return 'Quit'; }
        case SDLEventType.LowMemory: { return 'LowMemory'; }
        case SDLEventType.KeyDown: { return 'KeyDown'; }
        case SDLEventType.KeyUp: { return 'KeyUp'; }
        case SDLEventType.MouseMove: { return 'MouseMove'; }
        case SDLEventType.MouseDown: { return 'MouseDown'; }
        case SDLEventType.MouseUp: { return 'MouseUp'; }
        case SDLEventType.MouseScroll: { return 'MouseScroll'; }
        case SDLEventType.FingerDown: { return 'FingerDown'; }
        case SDLEventType.FingerUp: { return 'FingerUp'; }
        case SDLEventType.FingerDrag: { return 'FingerDrag'; }
        case SDLEventType.NotImplemented: { return 'NotImplemented'; }
    }
}

enum MouseButton {
    Left,
    Middle,
    Right,
    Unknown,
}

MouseButton MouseButtonFromInt(int val) => MouseButton.values[val];
int MouseButtonToInt(MouseButton val) => MouseButton.values.indexOf(val);

String MouseButtonToString(MouseButton val) {
    switch (val) {
        case MouseButton.Left: { return 'Left'; }
        case MouseButton.Middle: { return 'Middle'; }
        case MouseButton.Right: { return 'Right'; }
        case MouseButton.Unknown: { return 'Unknown'; }
    }
}

enum KeyCode {
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,
    One,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Zero,
    Exclamation,
    Question,
    DoubleQuote,
    SingleQuote,
    Pound,
    Dollar,
    Percent,
    Caret,
    Ampersand,
    Asterisk,
    Hyphen,
    Underscore,
    Equals,
    Plus,
    Pipe,
    Semicolon,
    Colon,
    At,
    Tilde,
    Hash,
    Backtick,
    ForwardSlash,
    BackSlash,
    NormalBracketL,
    NormalBracketR,
    SquareBracketL,
    SquareBracketR,
    CurlyBraceL,
    CurlyBraceR,
    SmallerThan,
    GreaterThan,
    Return,
    Escape,
    Backspace,
    Delete,
    Tab,
    Space,
    Insert,
    Home,
    End,
    PageUp,
    PageDown,
    ArrowRight,
    ArrowLeft,
    ArrowDown,
    ArrowUp,
    NumpadDivide,
    NumpadMultiply,
    NumpadSubtract,
    NumpadAdd,
    NumpadEquals,
    NumpadEnter,
    NumpadDecimalPoint,
    NumpadOne,
    NumpadTwo,
    NumpadThree,
    NumpadFour,
    NumpadFive,
    NumpadSix,
    NumpadSeven,
    NumpadEight,
    NumpadNine,
    NumpadZero,
    Function_F1,
    Function_F2,
    Function_F3,
    Function_F4,
    Function_F5,
    Function_F6,
    Function_F7,
    Function_F8,
    Function_F9,
    Function_F10,
    Function_F11,
    Function_F12,
    LControl,
    RControl,
    LShift,
    RShift,
    LAlt,
    RAlt,
    AudioNext,
    AudioPrev,
    AudioStop,
    AudioPlay,
    Unknown,
}

KeyCode KeyCodeFromInt(int val) => KeyCode.values[val];
int KeyCodeToInt(KeyCode val) => KeyCode.values.indexOf(val);

String KeyCodeToString(KeyCode val) {
    switch (val) {
        case KeyCode.A: { return 'A'; }
        case KeyCode.B: { return 'B'; }
        case KeyCode.C: { return 'C'; }
        case KeyCode.D: { return 'D'; }
        case KeyCode.E: { return 'E'; }
        case KeyCode.F: { return 'F'; }
        case KeyCode.G: { return 'G'; }
        case KeyCode.H: { return 'H'; }
        case KeyCode.I: { return 'I'; }
        case KeyCode.J: { return 'J'; }
        case KeyCode.K: { return 'K'; }
        case KeyCode.L: { return 'L'; }
        case KeyCode.M: { return 'M'; }
        case KeyCode.N: { return 'N'; }
        case KeyCode.O: { return 'O'; }
        case KeyCode.P: { return 'P'; }
        case KeyCode.Q: { return 'Q'; }
        case KeyCode.R: { return 'R'; }
        case KeyCode.S: { return 'S'; }
        case KeyCode.T: { return 'T'; }
        case KeyCode.U: { return 'U'; }
        case KeyCode.V: { return 'V'; }
        case KeyCode.W: { return 'W'; }
        case KeyCode.X: { return 'X'; }
        case KeyCode.Y: { return 'Y'; }
        case KeyCode.Z: { return 'Z'; }
        case KeyCode.One: { return '1'; }
        case KeyCode.Two: { return '2'; }
        case KeyCode.Three: { return '3'; }
        case KeyCode.Four: { return '4'; }
        case KeyCode.Five: { return '5'; }
        case KeyCode.Six: { return '6'; }
        case KeyCode.Seven: { return '7'; }
        case KeyCode.Eight: { return '8'; }
        case KeyCode.Nine: { return '9'; }
        case KeyCode.Zero: { return '0'; }
        case KeyCode.Exclamation: { return '!'; }
        case KeyCode.Question: { return '?'; }
        case KeyCode.DoubleQuote: { return '"'; }
        case KeyCode.SingleQuote: { return '\''; }
        case KeyCode.Pound: { return '£'; }
        case KeyCode.Dollar: { return '\$'; }
        case KeyCode.Percent: { return '%'; }
        case KeyCode.Caret: { return '^'; }
        case KeyCode.Ampersand: { return '&'; }
        case KeyCode.Asterisk: { return '*'; }
        case KeyCode.Hyphen: { return '-'; }
        case KeyCode.Underscore: { return '_'; }
        case KeyCode.Equals: { return '='; }
        case KeyCode.Plus: { return '+'; }
        case KeyCode.Pipe: { return '|'; }
        case KeyCode.Semicolon: { return ';'; }
        case KeyCode.Colon: { return ':'; }
        case KeyCode.At: { return '@'; }
        case KeyCode.Tilde: { return '~'; }
        case KeyCode.Hash: { return '#'; }
        case KeyCode.Backtick: { return '`'; }
        case KeyCode.ForwardSlash: { return '/'; }
        case KeyCode.BackSlash: { return '\\'; }
        case KeyCode.NormalBracketL: { return '('; }
        case KeyCode.NormalBracketR: { return ')'; }
        case KeyCode.SquareBracketL: { return '['; }
        case KeyCode.SquareBracketR: { return ']'; }
        case KeyCode.CurlyBraceL: { return '{'; }
        case KeyCode.CurlyBraceR: { return '}'; }
        case KeyCode.SmallerThan: { return '<'; }
        case KeyCode.GreaterThan: { return '>'; }
        case KeyCode.Return: { return 'Return'; }
        case KeyCode.Escape: { return 'Escape'; }
        case KeyCode.Backspace: { return 'Backspace'; }
        case KeyCode.Delete: { return 'Delete'; }
        case KeyCode.Tab: { return 'Tab'; }
        case KeyCode.Space: { return 'Space'; }
        case KeyCode.Insert: { return 'Insert'; }
        case KeyCode.Home: { return 'Home'; }
        case KeyCode.End: { return 'End'; }
        case KeyCode.PageUp: { return 'PageUp'; }
        case KeyCode.PageDown: { return 'PageDown'; }
        case KeyCode.ArrowRight: { return 'ArrowRight'; }
        case KeyCode.ArrowLeft: { return 'ArrowLeft'; }
        case KeyCode.ArrowDown: { return 'ArrowDown'; }
        case KeyCode.ArrowUp: { return 'ArrowUp'; }
        case KeyCode.NumpadDivide: { return 'NumpadDivide'; }
        case KeyCode.NumpadMultiply: { return 'NumpadMultiply'; }
        case KeyCode.NumpadSubtract: { return 'NumpadSubtract'; }
        case KeyCode.NumpadAdd: { return 'NumpadAdd'; }
        case KeyCode.NumpadEquals: { return 'NumpadEquals'; }
        case KeyCode.NumpadEnter: { return 'NumpadEnter'; }
        case KeyCode.NumpadDecimalPoint: { return 'NumpadDecimalPoint'; }
        case KeyCode.NumpadOne: { return '1'; }
        case KeyCode.NumpadTwo: { return '2'; }
        case KeyCode.NumpadThree: { return '3'; }
        case KeyCode.NumpadFour: { return '4'; }
        case KeyCode.NumpadFive: { return '5'; }
        case KeyCode.NumpadSix: { return '6'; }
        case KeyCode.NumpadSeven: { return '7'; }
        case KeyCode.NumpadEight: { return '8'; }
        case KeyCode.NumpadNine: { return '9'; }
        case KeyCode.NumpadZero: { return '0'; }
        case KeyCode.Function_F1: { return 'F1'; }
        case KeyCode.Function_F2: { return 'F2'; }
        case KeyCode.Function_F3: { return 'F3'; }
        case KeyCode.Function_F4: { return 'F4'; }
        case KeyCode.Function_F5: { return 'F5'; }
        case KeyCode.Function_F6: { return 'F6'; }
        case KeyCode.Function_F7: { return 'F7'; }
        case KeyCode.Function_F8: { return 'F8'; }
        case KeyCode.Function_F9: { return 'F9'; }
        case KeyCode.Function_F10: { return 'F10'; }
        case KeyCode.Function_F11: { return 'F11'; }
        case KeyCode.Function_F12: { return 'F12'; }
        case KeyCode.LControl: { return 'LControl'; }
        case KeyCode.RControl: { return 'RControl'; }
        case KeyCode.LShift: { return 'LShift'; }
        case KeyCode.RShift: { return 'RShift'; }
        case KeyCode.LAlt: { return 'LAlt'; }
        case KeyCode.RAlt: { return 'RAlt'; }
        case KeyCode.AudioNext: { return 'AudioNext'; }
        case KeyCode.AudioPrev: { return 'AudioPrev'; }
        case KeyCode.AudioStop: { return 'AudioStop'; }
        case KeyCode.AudioPlay: { return 'AudioPlay'; }
        case KeyCode.Unknown: { return 'Unknown'; }
    }
}

// ----------FUNC SIG TYPEDEFS FOR CLASSES----------

// ----------EVENT----------

// void* CreateEvent()
typedef _libEvent_class_Event_method_CreateEvent_native_sig = Pointer<Void> Function();
typedef _libEvent_class_Event_method_CreateEvent_sig = Pointer<Void> Function();

// void FreeEvent(void* struct_ptr)
typedef _libEvent_class_Event_method_FreeEvent_native_sig = Void Function(Pointer<Void>);
typedef _libEvent_class_Event_method_FreeEvent_sig = void Function(Pointer<Void>);

// SDLEventType GetEventType(void* struct_ptr)
typedef _libEvent_class_Event_method_GetEventType_native_sig = Int32 Function(Pointer<Void>);
typedef _libEvent_class_Event_method_GetEventType_sig = int Function(Pointer<Void>);

// int Poll(void* struct_ptr)
typedef _libEvent_class_Event_method_Poll_native_sig = Int32 Function(Pointer<Void>);
typedef _libEvent_class_Event_method_Poll_sig = int Function(Pointer<Void>);

// void GetMouseMoveData(void* struct_ptr, int* x, int* y)
typedef _libEvent_class_Event_method_GetMouseMoveData_native_sig = Void Function(Pointer<Void>, Pointer<Int32>, Pointer<Int32>);
typedef _libEvent_class_Event_method_GetMouseMoveData_sig = void Function(Pointer<Void>, Pointer<Int32>, Pointer<Int32>);

// MouseButton GetMousePressReleaseData(void* struct_ptr, int* x, int* y)
typedef _libEvent_class_Event_method_GetMousePressReleaseData_native_sig = Int32 Function(Pointer<Void>, Pointer<Int32>, Pointer<Int32>);
typedef _libEvent_class_Event_method_GetMousePressReleaseData_sig = int Function(Pointer<Void>, Pointer<Int32>, Pointer<Int32>);

// KeyCode GetKeyPressReleaseData(void* struct_ptr)
typedef _libEvent_class_Event_method_GetKeyPressReleaseData_native_sig = Int32 Function(Pointer<Void>);
typedef _libEvent_class_Event_method_GetKeyPressReleaseData_sig = int Function(Pointer<Void>);

// ----------CLASS IMPLEMENTATIONS----------

class Event {
    Pointer<Void> structPointer = nullptr;

    void _validatePointer(String methodName) {
        if (structPointer.address == 0) {
            throw Exception('Event.$methodName was called, but structPointer is a nullptr.');
        }
    }

    static _libEvent_class_Event_method_CreateEvent_sig? _CreateEvent;
    static _libEvent_class_Event_method_FreeEvent_sig? _FreeEvent;
    static _libEvent_class_Event_method_GetEventType_sig? _GetEventType;
    static _libEvent_class_Event_method_Poll_sig? _Poll;
    static _libEvent_class_Event_method_GetMouseMoveData_sig? _GetMouseMoveData;
    static _libEvent_class_Event_method_GetMousePressReleaseData_sig? _GetMousePressReleaseData;
    static _libEvent_class_Event_method_GetKeyPressReleaseData_sig? _GetKeyPressReleaseData;

    void _initRefs() {
        if (
            _CreateEvent == null ||
            _FreeEvent == null ||
            _GetEventType == null ||
            _Poll == null ||
            _GetMouseMoveData == null ||
            _GetMousePressReleaseData == null ||
            _GetKeyPressReleaseData == null
        ) {
            final lib = DynamicLibrary.open('build/native/SDL/libEvent.so');

            _CreateEvent = lib.lookupFunction<_libEvent_class_Event_method_CreateEvent_native_sig, _libEvent_class_Event_method_CreateEvent_sig>('CreateEvent');
            _FreeEvent = lib.lookupFunction<_libEvent_class_Event_method_FreeEvent_native_sig, _libEvent_class_Event_method_FreeEvent_sig>('FreeEvent');
            _GetEventType = lib.lookupFunction<_libEvent_class_Event_method_GetEventType_native_sig, _libEvent_class_Event_method_GetEventType_sig>('GetEventType');
            _Poll = lib.lookupFunction<_libEvent_class_Event_method_Poll_native_sig, _libEvent_class_Event_method_Poll_sig>('Poll');
            _GetMouseMoveData = lib.lookupFunction<_libEvent_class_Event_method_GetMouseMoveData_native_sig, _libEvent_class_Event_method_GetMouseMoveData_sig>('GetMouseMoveData');
            _GetMousePressReleaseData = lib.lookupFunction<_libEvent_class_Event_method_GetMousePressReleaseData_native_sig, _libEvent_class_Event_method_GetMousePressReleaseData_sig>('GetMousePressReleaseData');
            _GetKeyPressReleaseData = lib.lookupFunction<_libEvent_class_Event_method_GetKeyPressReleaseData_native_sig, _libEvent_class_Event_method_GetKeyPressReleaseData_sig>('GetKeyPressReleaseData');
        }
    }

    Event() {
        _initRefs();
        structPointer = _CreateEvent!();
    }

    Event.fromPointer(Pointer<Void> ptr) {
        _initRefs();
        structPointer = ptr;
    }

    @mustCallSuper
    void Free() {
        _validatePointer('Free');
        final out = _FreeEvent!(structPointer);

        // this method invalidates the pointer, probably by freeing memory
        structPointer = Pointer.fromAddress(0);

        return out;
    }

    SDLEventType get type {
        _validatePointer('type');
        return SDLEventTypeFromInt(_GetEventType!(structPointer));
    }

    int Poll() {
        _validatePointer('Poll');
        return _Poll!(structPointer);
    }

    void GetMouseMoveData(Pointer<Int32> x, Pointer<Int32> y) {
        _validatePointer('GetMouseMoveData');
        return _GetMouseMoveData!(structPointer, x, y);
    }

    MouseButton GetMousePressReleaseData(Pointer<Int32> x, Pointer<Int32> y) {
        _validatePointer('GetMousePressReleaseData');
        return MouseButtonFromInt(_GetMousePressReleaseData!(structPointer, x, y));
    }

    KeyCode GetKeyPressReleaseData() {
        _validatePointer('GetKeyPressReleaseData');
        return KeyCodeFromInt(_GetKeyPressReleaseData!(structPointer));
    }

}

