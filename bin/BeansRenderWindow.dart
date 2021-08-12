import 'dart_codegen.dart';
import 'FontCache.dart';

class BeansRenderWindow extends RenderWindow {
  BeansRenderWindow() : super('Beans');

  void DrawPointC(int x, int y, int r, int g, int b, [int a = 255]) {
    SetColour(r, g, b, a);
    DrawPoint(x, y);
  }
  void DrawLineC(int x1, int y1, int x2, int y2, int r, int g, int b, [int a=255]) {
    SetColour(r, g, b, a);
    DrawLine(x1, y1, x2, y2);
  }
  void DrawRectC(int x, int y, int w, int h, int r, int g, int b, [int a = 255]) {
    SetColour(r, g, b, a);
    DrawRect(x, y, w, h);
  }
  void FillRectC(int x, int y, int w, int h, int r, int g, int b, [int a = 255]) {
    SetColour(r, g, b, a);
    FillRect(x, y, w, h);
  }

  /// Default text drawing functions are weird around newlines
  void DrawText(String text, int x, int y, int r, int g, int b, {int a = 255, BeansFont? font}) {
    font ??= FontCache.family().font();
    final lines = text.split('\n');
    var lineY = y;
    for (var line in lines) {
      // can't draw an empty string - GetTextTexture fails.
      // we still need to add the line height though
      if (line != '') {
        cDrawText(font, line, x, lineY, r, g, b, a);
      }
      lineY += font.GetTextHeight(line);
    }
  }

  // for the default scale
  // todo: i really need to implement default parameters in codegen
  void DrawImage(Image image, int x, int y, [double scale = 1]) {
    cDrawImage(image, x, y, scale);
  }
}