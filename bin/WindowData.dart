import 'BeansWindow.dart';
import 'V2.dart';
import 'TitleBarIcon.dart';
import 'BeansRenderWindow.dart';
import 'Config.dart';
import 'BeansAssert.dart';
import 'Colour.dart';

/// WindowData represents metadata about a [BeansWindow], needed by the [BeansWindowManager].
class WindowData {
  V2 size;
  bool isFocused;
  bool isFloating;
  BeansWindow window;
  final _conf = Config.instance;

  final void Function(WindowData, V2, V2) onDragStart;
  final void Function(WindowData) onClose;
  late final TitleBarIcon cross;
  late final TitleBarIcon dt;

  WindowData({
    required this.size,
    required this.isFocused,
    required this.isFloating,
    required this.window,
    required this.onClose,
    required this.onDragStart
  }) {
    print(size);
    cross = TitleBarCross(() => onClose(this));
    dt = TitleBarDragTarget((windowPos, mousePos) => onDragStart(this, windowPos, mousePos));
  }

  /// Tests if the event at [hit] occured inside this window.
  /// [hitTest] is *inclusive* on the left/top and *exclusive* on the right/bottom.
  bool hitTest(V2 windowPos, V2 hit) {
    return (windowPos + V2(0, _conf.windowTitleBar.height))
      .hitTest(size, hit);
  }

  bool hitTestWithTitleBar(V2 windowPos, V2 hit) {
    final tbHeight = _conf.windowTitleBar.height;
    return windowPos.hitTest(size + V2(0, tbHeight), hit);
  }

  /// Tests if the event at [hit] occured inside this window's title bar.
  bool isInTitleBar(V2 windowPos, V2 hit) {
    return _tbPos(windowPos).hitTest(_tbSize(windowPos), hit);
  }

  V2 _tbPos(V2 windowPos) => V2(windowPos.x, windowPos.y);
  V2 _tbSize(V2 windowPos) => V2(size.x, _conf.windowTitleBar.height);

  /// Render [window] using [x], [y], [width] and [height].
  void render(BeansRenderWindow rw, V2 windowPos, bool showDecorations) {
    BeansAssert(
      size.x >= window.minSize.x &&
      size.y >= window.minSize.y,
      'Window ${window.title} has a minSize of ${window.minSize}, but we attempted to render it with a size of $size.'
    );
    window.render(rw, windowPos.clone()..y += _conf.windowTitleBar.height, size);
    _renderBoundingBox(rw, windowPos);
    if (showDecorations) {
      _renderWindowDecorations(rw, windowPos);
    }
  }

  void _renderWindowDecorations(BeansRenderWindow rw, V2 windowPos) {
    final tbPos = _tbPos(windowPos);
    final tbSize = _tbSize(windowPos);

    // bg col
    //rw.FillRect(tbPos, tbSize, window.titleBarBGCol);
    // bar
    rw.FillRect(tbPos, tbSize, _conf.windowTitleBar.col);

    cross.render(rw, windowPos, size);
    dt.render(rw, windowPos, size);
  }

  // show a red box around the outside of the window, for debugging purposes
  void _renderBoundingBox(BeansRenderWindow rw, V2 windowPos, [int thickness = 15]) {
    final col = Colours.red;
    windowPos = windowPos
      .clone()
      ..y += _conf.windowTitleBar.height;

    rw.FillRect(windowPos, V2(size.x, thickness), col);
    rw.FillRect(windowPos, V2(thickness, size.y), col);
    rw.FillRect(windowPos.clone()..y += (size.y - thickness), V2(size.x, thickness), col);
    rw.FillRect(windowPos.clone()..x += (size.x - thickness), V2(thickness, size.y), col);
  }

  int x2(int x) => x + size.x;
  int y2(int y) => y + size.y;
}