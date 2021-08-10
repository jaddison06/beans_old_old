import 'dart_codegen.dart';

/// BeansWindow is an interface that represents a window which can be drawn by a [BeansWindowManager].
/// Although it's abstract, I recommend extending it instead of implementing it, as it will provide lots of
/// helper methods for interacting with the [BeansWindowManager].
abstract class BeansWindow {
  int get minWidth;
  int get minHeight;
  String get title;

  void render(RenderWindow rw, int x, int y, int width, int height);

  // empty bodies provided - you don't have to override these if you just want some kinda info display window
  void onKeyDown(KeyCode key) {}
  void onMouseMove(int x, int y) {}
  void onMouseDown(int x, int y, MouseButton button) {}
}