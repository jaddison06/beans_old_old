import 'dart_codegen.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

class V2 {
  final int x;
  final int y;
  V2(this.x, this.y);
}

class Beans {
  final RenderWindow _rw;
  final Event _event;

  // for getting event coord data
  Pointer<Int32> _x;
  Pointer<Int32> _y;

  bool _shouldQuit = false;

  bool _collectPoints = false;
  List<V2> _points = [];

  Beans() :
    _rw = RenderWindow("beans"),
    _event = Event(),
    _x = malloc<Int32>(),
    _y = malloc<Int32>();
  
  void destroy() {
    _rw.Destroy();
    _event.Free();
    malloc.free(_x);
    malloc.free(_y);
  }

  void quit() {
    _shouldQuit = true;
  }

  void render() {
    _rw.SetColour(255, 255, 0, 255);
    _rw.FillRect(_x.value, _y.value, 69, 69);
    _rw.SetColour(255, 255, 0, 255);
    for (var point in _points) {
      _rw.DrawPoint(point.x, point.y);
    }
  }

  void _paint() {
    render();
    _rw.Flush();
  }

  void _addPoint() {
    _points.add(V2(_x.value, _y.value));
  }

  void _processAllEvents() {
    while (_event.Poll() > 0) {
      switch (_event.type) {
        case SDLEventType.Quit: {
          quit();
          break;
        }

        case SDLEventType.KeyDown: {
          switch (_event.GetKeyPressReleaseData()) {
            case KeyCode.Escape: {
              // could just return here - no need to keep processing events
              //quit();
              break;
            }

            default: {}
          }
          break;
        }

        case SDLEventType.MouseDown: {
          switch (_event.GetMousePressReleaseData(_x, _y)) {
            case MouseButton.Left: {
              _collectPoints = true;
              _addPoint();
              break;
            }

            case MouseButton.Right: {
              quit();
              break;
            }

            default: {}
          }
          break;
        }
        case SDLEventType.MouseUp: {
          _collectPoints = false;
          break;
        }

        case SDLEventType.MouseMove: {
          _event.GetMouseMoveData(_x, _y);
          if (_collectPoints) {
            _addPoint();
          }
          break;
        }

        default: {}
      }
    }
  }
  
  void run() {
    final start = DateTime.now();

    while (!_shouldQuit) {
      _paint();
      _processAllEvents();
    }

    final end = DateTime.now();
    final frames = _rw.frameCount;
    final milliseconds = end.difference(start).inMilliseconds.toDouble();
    final seconds = milliseconds / 1000;
    final fps = frames / seconds;
    print('$frames frames in ${milliseconds}ms or ${seconds}s = ${fps.round()}fps');

  }
}

Future<void> main() async {
  final beans = Beans();
  beans.run();
  beans.destroy();
}