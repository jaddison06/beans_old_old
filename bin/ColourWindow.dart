import 'dart_codegen.dart';
import 'BeansWindow.dart';
import 'BeansRenderWindow.dart';

class ColourWindow extends BeansWindow {
  @override
  final int minWidth;
  @override
  final int minHeight;

  final int r, g, b;
  final void Function() onClick;

  static int instanceCount = 0;
  final bool _showError;

  ColourWindow({
    required this.minWidth,
    required this.minHeight,
    required this.r,
    required this.g,
    required this.b,
    required this.onClick
  }) : _showError = instanceCount % 2 == 0 {
    instanceCount++;
  }

  @override
  String get title => 'ColourWindow($r, $g, $b)';

  @override
  void render(BeansRenderWindow rw, int x, int y, int width, int height) {
    if (_showError) {
      throw Exception('your mum');
    }
    rw.FillRectC(x, y, width, height, r, g, b);
  }

  @override
  void onMouseDown(int x, int y, MouseButton button) {
    onClick();
  }

}