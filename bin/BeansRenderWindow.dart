import 'dart_codegen.dart';
import 'FontCache.dart';
import 'Colour.dart';
import 'V2.dart';

/// RenderWindow but with sexy Dart types
class BeansRenderWindow extends RenderWindow {
  BeansRenderWindow() : super('Beans');

  void SetColour([Colour? colour]) {
    if (colour == null) return;
    cSetColour(colour.r, colour.g, colour.b, colour.a);
  }

  void DrawPoint(V2 pos, [Colour? colour]) {
    SetColour(colour);
    cDrawPoint(pos.x, pos.y);
  }
  void DrawLine(V2 pos1, V2 pos2, [Colour? colour]) {
    SetColour(colour);
    cDrawLine(pos1.x, pos1.y, pos2.x, pos2.y);
  }
  void DrawRect(V2 pos, V2 size, [Colour? colour]) {
    SetColour(colour);
    cDrawRect(pos.x, pos.y, size.x, size.y);
  }
  void FillRect(V2 pos, V2 size, [Colour? colour]) {
    SetColour(colour);
    cFillRect(pos.x, pos.y, size.x, size.y);
  }

  /// Default text drawing functions are weird around newlines
  void DrawText(String text, V2 pos, Colour colour, [BeansFont? font]) {
    font ??= FontCache.family().font();
    final lines = text.split('\n');
    var lineY = pos.y;
    for (var line in lines) {
      // can't draw an empty string - GetTextTexture fails.
      // we still need to add the line height though
      if (line != '') {
        cDrawText(font, line, pos.x, lineY, colour.r, colour.g, colour.b, colour.a);
      }
      lineY += font.GetTextHeight(line);
    }
  }

  void DrawImage(Image image, V2 pos, [double scale = 1]) {
    cDrawImage(image, pos.x, pos.y, scale);
  }


}