import 'dart_codegen.dart';

/// BeansRenderer is the main class used to interface with the C [RenderWindow]
/// from Dart code. It takes care of the event loop & makes sure the window
/// is painted and cleared properly. It is **not** responsible for cleaning up
/// the [RenderWindow]`
class BeansRenderer {
  final RenderWindow rw;
  final Event _event;

  bool _shouldQuit = false;

  final void Function(RenderWindow) render;
  final void Function(Event) event;

  /// [rw] is the [RenderWindow] that will be used for rendering.
  /// [render] is a callback that should draw graphics to the [RenderWindow]. It should **not** call [RenderWindow.Flush].
  /// [event] is a callback that should handle events that occur. [BeansRenderer] takes care of polling events every frame,
  /// so the caller only needs to process the event that is passed to them.
  BeansRenderer({
    required this.rw,
    required this.render,
    required this.event
  }) :
    _event = Event();
  
  /// Cleans up memory associated with the [BeansRenderer]`.
  void destroy() {
    _event.Free();
  }

  /// Tells the [BeansRenderer]` that it should quit **after the next frame**.
  void quit() {
    _shouldQuit = true;
  }

  void _paint() {
    render(rw);
    rw.Flush();
  }

  void _processAllEvents() {
    while (_event.Poll() > 0) {
      event(_event);
    }
  }
  
  /// Starts the event loop. This will block until the window is closed.
  void run() {
    final start = DateTime.now();

    while (!_shouldQuit) {
      _paint();
      _processAllEvents();
    }

    final end = DateTime.now();
    final frames = rw.frameCount;
    final milliseconds = end.difference(start).inMilliseconds.toDouble();
    final seconds = milliseconds / 1000;
    final fps = frames / seconds;
    print('$frames frames in ${milliseconds}ms or ${seconds}s = ${fps.round()}fps');

  }
}