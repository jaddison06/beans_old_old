import 'BeansRenderWindow.dart';
import 'Config.dart';
import 'V2.dart';
import 'dart_codegen.dart';

abstract class TitleBarIcon {
  final conf = Config.instance;

  bool isHovered = false;
  bool isPressed = false;

  final void Function(V2, V2)? mouseDownCallback;
  final void Function()? successfulClickCallback;

  TitleBarIcon({this.mouseDownCallback, this.successfulClickCallback});

  int get rOffset;
  
  bool onMouseMove(V2 windowPos, V2 windowSize, V2 mousePos) {
    isHovered = hitTest(windowPos, windowSize, mousePos);
    return isHovered;
  }

  bool onMouseDown(V2 windowPos, V2 windowSize, MouseButton button, V2 mousePos) {
    if (button != MouseButton.Left) return false;

    isPressed = hitTest(windowPos, windowSize, mousePos);

    if (isPressed) mouseDownCallback?.call(windowPos, mousePos);

    return isPressed;
  }

  bool onMouseUp(V2 windowPos, V2 windowSize, MouseButton button, V2 mousePos) {
    if (!isPressed) return false;
    isPressed = false;

    if (hitTest(windowPos, windowSize, mousePos)) {
      successfulClickCallback?.call();
      return true;
    }

    return false;
  }

  bool hitTest(V2 windowPos, V2 windowSize, V2 hit) {
    return iconPos(windowPos, windowSize).hitTest(iconSize, hit);
  }

  V2 get iconSize => V2.square(conf.windowTitleBar.iconSize);
  V2 iconPos(V2 windowPos, V2 windowSize) {
    final tbX2 = windowPos.x + windowSize.x;
    final tbY = windowPos.y - conf.windowTitleBar.height;

    final padding = (conf.windowTitleBar.height - conf.windowTitleBar.iconSize) ~/ 2;
    final iconY = tbY + padding;
    
    return V2(
      tbX2 - rOffset,
      iconY
    );
  }

  void drawIconBox(BeansRenderWindow rw, V2 windowPos, V2 windowSize, bool clicking) {
    rw.FillRect(iconPos(windowPos, windowSize), iconSize, clicking ? conf.windowTitleBar.iconClickCol : conf.windowTitleBar.iconHoverCol);
  }

  void renderIcon(BeansRenderWindow rw, V2 windowPos, V2 windowSize);

  void render(BeansRenderWindow rw, V2 windowPos, V2 windowSize) {
    //* order is important because if isPressed is true then isHovered will also be true !!
    if (isPressed) {
      drawIconBox(rw, windowPos, windowSize, true);
    } else if (isHovered) {
      drawIconBox(rw, windowPos, windowSize, false);
    }

    rw.SetColour(conf.windowTitleBar.iconCol);
    renderIcon(rw, windowPos, windowSize);
  }

}

class TitleBarCross extends TitleBarIcon {
  TitleBarCross(void Function() onClose) : super(successfulClickCallback: onClose);
  @override
  int get rOffset => conf.windowTitleBar.crossROffset;
  @override
  void renderIcon(BeansRenderWindow rw, V2 windowPos, V2 windowSize) {
    final pos = iconPos(windowPos, windowSize);
    final pos2 = pos + iconSize;
    rw.DrawLine(pos, pos2);
    rw.DrawLine(
      V2(pos2.x, pos.y),
      V2(pos.x, pos2.y)
    );
  }
}

class TitleBarDragTarget extends TitleBarIcon {
  TitleBarDragTarget(void Function(V2, V2) onDragStart) : super(mouseDownCallback: onDragStart);
  @override
  int get rOffset => conf.windowTitleBar.dtROffset;
  @override
  void renderIcon(BeansRenderWindow rw, V2 windowPos, V2 windowSize) {
    final pos = iconPos(windowPos, windowSize);
    final size = conf.windowTitleBar.iconSize;
    final thickness = 3;
    // not the distance between a's end and b's start, but between a's start and b's start.
    final gap = (size / 2) - (thickness / 2);
    for (var i=0; i<3; i++) {
      for (var j=0; j<3; j++) {
        final offset = V2(
          (i * gap).toInt(),
          (j * gap).toInt()
        );
        rw.FillRect(
          pos + offset,
          V2.square(thickness)
        );
      }
    }
  }
}