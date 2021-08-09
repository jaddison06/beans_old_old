import 'dart_codegen.dart';

/// BeansWindow is an interface that represents a window which can be drawn by a BeansWindowManager.
abstract class BeansWindow {
  int get minWidth;
  int get minHeight;

  void render(RenderWindow rw, int x, int y, int width, int height);

  void onKeyDown(KeyCode key);
  void onMouseMove(int x, int y);
  void onMouseDown(int x, int y, MouseButton button);
}