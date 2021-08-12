import 'BeansWindow.dart';
import 'BeansRenderWindow.dart';
import 'Colour.dart';
import 'V2.dart';

class ColourWindow extends BeansWindow {
  @override
  final V2 minSize;
  
  final Colour colour;

  ColourWindow({
    required this.minSize,
    required this.colour,
  });

  @override
  String get title => 'ColourWindow($colour)';

  @override
  Colour get titleBarBGCol => colour;

  @override
  void render(BeansRenderWindow rw, V2 pos, V2 size) {
    rw.FillRect(pos, size, colour);
  }

}