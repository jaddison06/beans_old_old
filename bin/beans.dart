import 'dart_codegen.dart';
import 'BeansWindowManager.dart';
import 'dart:io';

/// Beans is responsible for initialization, error handling & cleanup at
/// the highest level. It creates the [RenderWindow] and the [BeansWindowManager].
class Beans {
  late final RenderWindow _rw;
  late final BeansWindowManager _wm;

  Beans() {
    _rw = RenderWindow('beans');
    if (_rw.errorCode != SDLInitCode.Success) {
      _panic(SDLInitCodeToString(_rw.errorCode));
    }
    _wm = BeansWindowManager(_rw);
  }

  /// panic w/ terminal output
  Never _panic(String msg) {
    print(msg);
    exit(0);
  }

  /// Start the event loop
  void start() {
    try {
      _wm.start();
    } catch (e, trace) {
      destroy();
      _panic('Exception:\n$e\nOccured at:\n$trace');
    }
  }

  /// Free resources
  void destroy() {
    _wm.destroy();
    _rw.Destroy();
  }
}

void main() {
  final beans = Beans();
  beans.start();
  beans.destroy();
}