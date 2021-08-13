import 'BeansRenderWindow.dart';
import 'V2.dart';
import 'Colour.dart';
import 'dart_codegen.dart';
import 'FontCache.dart';
import 'XYPointer.dart';

class TextButton extends XYPointer {
  final V2 pos;
  final String text;
  final BeansFont font;
  final Colour textCol;
  final Colour buttonCol;
  final int padding;
  final void Function() onClick;

  bool _isPressed = false;

  V2 get size {
    font.GetTextSize(text, xPtr, yPtr);
    return v2FromPointers() + V2.square(padding * 2);
  }

  TextButton({required this.pos, required this.text, required this.onClick, this.padding = 5, Colour? buttonCol, Colour? textCol, String? fontFamily, int? fontPt, int? fontPx}) :
    buttonCol = buttonCol ?? Colours.white,
    textCol = textCol ?? Colours.black,
    font = FontCache.family(fontFamily).font(pt: fontPt, px: fontPx);

  void render(BeansRenderWindow rw) {
    rw.FillRect(pos, size, buttonCol);
    rw.DrawText(text, pos + V2.square(padding), textCol);
  }

  bool onMouseDown(MouseButton button, V2 hit) {
    if (button != MouseButton.Left) return false;

    _isPressed = pos.hitTest(size, hit);
    return _isPressed;
  }

  bool onMouseUp(MouseButton button, V2 hit) {
    if (!_isPressed) return false;
    _isPressed = false;

    if (pos.hitTest(size, hit)) {
      onClick();
      return true;
    }

    return false;
  }
}