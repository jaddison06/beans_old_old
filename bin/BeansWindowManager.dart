import 'BeansWindow.dart';
import 'dart_codegen.dart';
import 'BeansRenderer.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// WindowData represents metadata about a BeansWindow, needed by the BeansWindowManager.
class WindowData {
  int x;
  int y;
  int width;
  int height;
  bool isFocused;
  bool isFloating;
  BeansWindow window;

  /// Tests if the event at (x, y) occured inside this window.
  /// hitTest is *inclusive* on the left/top and *exclusive* on the right/bottom.
  bool hitTest(int x, int y) {
    return (
      x >= this.x &&
      y >= this.y &&
      x < this.x + width &&
      y < this.y + height
    );
  }

  WindowData({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isFocused,
    required this.isFloating,
    required this.window
  });
}

/// BeansWindowManager is responsible for:
/// - Rendering BeansWindows
/// - Turning the raw Events from SDL into a more usable format
/// - Hit-testing windows and passing these events to them
/// - Allowing the user to resize, relocate, add, or remove windows
/// - Rendering window decorations and other UI elements
class BeansWindowManager {
  late final BeansRenderer _ren;

  final Pointer<Int32> _x;
  final Pointer<Int32> _y;

  final List<WindowData> _windows = [];

  BeansWindowManager(RenderWindow rw) :
    _x = malloc<Int32>(),
    _y = malloc<Int32>()
  {
    _ren = BeansRenderer(
      rw: rw,
      render: _render,
      event: _event
    );
  }

  /// Starts the event loop.
  void start() {
    _ren.run();
  }

  /// Destroys any memory that has been allocated
  void destroy() {
    _ren.destroy();
  }

  WindowData get _focusedWindow => _windows.where((wd) => wd.isFocused).first;
  WindowData get _hitWindow => _windows.where((wd) => wd.hitTest(_x.value, _y.value)).first;

  void _render(RenderWindow rw) {
    // todo: decorations etc
    for (var win in _windows) {
      win.window.render(
        rw,
        win.x,
        win.y,
        win.width,
        win.height
      );
    }
  }

  /// update the focused window based on _x and _y
  void _setFocusedWindow() {
    if (!_focusedWindow.hitTest(_x.value, _y.value)) {
      _focusedWindow.isFocused = false;
      for (var win in _windows) {
        if (win.hitTest(_x.value, _y.value)) {
          win.isFocused = true;
          break;
        }
      }
    }
  }

  void _event(Event event) {
    switch (event.type) {
      case SDLEventType.KeyDown: {
        _focusedWindow.window.onKeyDown(event.GetKeyPressReleaseData());
        break;
      }

      case SDLEventType.MouseMove: {
        event.GetMouseMoveData(_x, _y);

        _focusedWindow.window.onMouseMove(_x.value, _y.value);
        break;
      }

      case SDLEventType.MouseDown: {
        final button = event.GetMousePressReleaseData(_x, _y);
        _setFocusedWindow();
        
        _focusedWindow.window.onMouseDown(_x.value, _y.value, button);
        break;
      }

      default: {}
    }
  }
}