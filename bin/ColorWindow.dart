import 'dart:html';

import 'dart_codegen.dart';
import 'BeansWindow.dart';

class ColorWindow implements BeansWindow {
  @override
  final int minWidth;
  @override
  final int minHeight;

  final int r, g, b;

  ColorWindow(this.minWidth, this.minHeight, this.r, this.g, this.b);

  void render(RenderWindow rw, int x, int y, int width, int height) {
    rw.SetColour(r, g, b, 255);
    rw.FillRect(x, y, width, height);
  }

  void onKeyDown(KeyCode key) {}
  void onMouseMove(int x, int y) {}
  void onMouseDown(int x, int y, MouseButton button) {}

}