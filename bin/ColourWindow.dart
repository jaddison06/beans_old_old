import 'dart_codegen.dart';
import 'BeansWindow.dart';

class ColourWindow extends BeansWindow {
  @override
  final int minWidth;
  @override
  final int minHeight;

  final int r, g, b;
  final void Function() onClick;

  ColourWindow(this.minWidth, this.minHeight, this.r, this.g, this.b, this.onClick);

  @override
  void render(RenderWindow rw, int x, int y, int width, int height) {
    rw.SetColour(r, g, b, 255);
    rw.FillRect(x, y, width, height);
  }

  @override
  void onMouseDown(int x, int y, MouseButton button) {
    onClick();
  }

}