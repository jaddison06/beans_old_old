import 'dart_codegen.dart';
import 'BeansWindowManager.dart';

/// Beans is responsible for initialization, error handling & cleanup at
/// the highest level. It creates the RenderWindow and the BeansWindowManager.
class Beans {
  late final RenderWindow _rw;
  late final BeansWindowManager _wm;

  Beans() {
    _rw = RenderWindow('beans');
    _wm = BeansWindowManager(_rw);
  }

  void start() {
    _wm.start();
  }

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