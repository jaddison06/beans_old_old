import 'dart_codegen.dart';
import 'BeansRenderWindow.dart';
import 'CatchAll.dart';

/// BeansRenderer is the main class used to interface with the C in [BeansRenderWindow]
/// from Dart code. It takes care of the event loop & makes sure the window
/// is painted and cleared properly. It is **not** responsible for cleaning up
/// the [BeansRenderWindow]`
class BeansRenderer {
  final BeansRenderWindow rw;
  final Event _event;

  bool _shouldQuit = false;

  bool handleErrors = true;

  final void Function(BeansRenderWindow) render;
  final void Function(Event) event;
  final void Function(Object, StackTrace) onError;

  /// [rw] is the [BeansRenderWindow] that will be used for rendering.
  /// [render] is a callback that should draw graphics to the [BeansRenderWindow]. It should **not** call [BeansRenderWindow.Flush].
  /// [event] is a callback that should handle events that occur. [BeansRenderer] takes care of polling events every frame,
  /// so the caller only needs to process the event that is passed to them.
  BeansRenderer({
    required this.rw,
    required this.render,
    required this.event,
    required this.onError
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
    if (handleErrors) {
      catchAll(() => render(rw), onError);
    }
    else {
      render(rw);
    }
    rw.Flush();
  }

  void _processAllEvents() {
    while (_event.Poll() > 0) {
      if (handleErrors) {
        catchAll(() => event(_event), onError);
      } else {
        event(_event);
      }
    }
  }
  
  /// Starts the event loop. This will block until the window is closed.
  void run() {
    final start = DateTime.now();

    while (!_shouldQuit) {
      _processAllEvents();
      _paint();
    }

    final end = DateTime.now();
    final frames = rw.frameCount;
    final milliseconds = end.difference(start).inMilliseconds.toDouble();
    final seconds = milliseconds / 1000;
    final fps = frames / seconds;
    print('$frames frames in ${milliseconds}ms or ${seconds}s = ${fps.round()}fps');

  }
}