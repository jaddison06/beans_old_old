import 'dart_codegen.dart';
import 'BeansWindowManager.dart';
import 'dart:io';
import 'FontCache.dart';
import 'BeansRenderWindow.dart';

/// Beans is responsible for initialization, error handling & cleanup at
/// the highest level. It creates the [BeansRenderWindow] and the [BeansWindowManager].
class Beans {
  late final BeansRenderWindow _rw;
  late final BeansWindowManager _wm;

  Beans() {
    _rw = BeansRenderWindow();
    if (_rw.errorCode != SDLInitCode.Success) {
      _panic(SDLInitCodeToString(_rw.errorCode));
    }
    _wm = BeansWindowManager(_rw);

    FontCache.defaultFamily = 'res/DroidSansMono/DroidSansMono.ttf';
    FontCache.defaultSize = 24;
  }

  /// Something has gone seriously wrong and the WindowManager has died, so print a panic message to the terminal.
  Never _panic(String msg) {
    print(msg);
    destroy();
    exit(0);
  }

  /// execute some code with a catchall
  void _catchAll(void Function() code) {
    try {
      code();
    } catch (e, trace) {
      _panic('A fatal exception occured within Beans:\n$e\nOccured at:\n$trace');
    }
  }

  /// Start the event loop
  void start() {
    _catchAll(() => _wm.start());
  }

  /// Free resources
  void destroy() {
    //* must be called before TTF_Quit() in RenderWindow.Destroy()
    FontCache.destroyAll();

    _wm.destroy();
    _rw.Destroy();
  }
}

void main() {
  final beans = Beans();
  beans.start();
  beans.destroy();
}