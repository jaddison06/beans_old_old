import 'dart_codegen.dart';
import 'BeansRenderWindow.dart';
import 'Colour.dart';
import 'V2.dart';

/// BeansWindow is an interface that represents a window which can be drawn by a [BeansWindowManager].
/// Although it's abstract, I recommend extending it instead of implementing it, as it will provide lots of
/// helper methods for interacting with the [BeansWindowManager].
abstract class BeansWindow {
  V2 get minSize;
  String get title;

  // optional colour to display behind the titlebar
  Colour get titleBarBGCol => Colours.black;

  void render(BeansRenderWindow rw, V2 pos, V2 size);

  // empty bodies provided - you don't have to override these if you just want some kinda info display window
  void onKeyDown(KeyCode key) {}
  void onMouseMove(int x, int y) {}
  void onMouseDown(int x, int y, MouseButton button) {}
}