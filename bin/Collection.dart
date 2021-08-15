import 'XYPointer.dart';
import 'WindowData.dart';
import 'TitleBarIcon.dart';
import 'BeansWindowManager.dart';
import 'Config.dart';
import 'dart_codegen.dart';
import 'V2.dart';
import 'BeansRenderWindow.dart';

/// A row or column of windows
class Collection extends XYPointer {

  final _conf = Config.instance;

  final windows = <WindowData>[];

  bool get isColumns => BeansWindowManager.isColumns;

  void setCrossSize(int newCrossSize) {
    for (var wd in windows) {
      wd.size.cross = newCrossSize;
    }
  }

  // assume all windows have the same cross size, which they *should*
  int get crossSize => windows.isEmpty ? 0 : windows.last.size.cross;

  bool? _tbForEach(bool Function(WindowData, TitleBarIcon, int) cb) {
    return _forEachWithMainPos((wd, mainPos) => (
        (cb(wd, wd.cross, mainPos) ||
        cb(wd, wd.dt   , mainPos)) ?
        //! because of what goes on a *long* way up the call chain, this CANNOT return false. If you want falsy, it needs to be null.
        true : null
    ));
  }

  bool? tbOnMouseMove(int crossPos, V2 mousePos) {
    return _tbForEach((wd, icon, mainPos) => icon.onMouseMove(V2.fromMC(mainPos, crossPos), wd.size, mousePos));
  }
  
  bool? tbOnMouseDown(int crossPos, MouseButton button, V2 mousePos) {
    return _tbForEach((wd, icon, mainPos) => icon.onMouseDown(V2.fromMC(mainPos, crossPos), wd.size, button, mousePos));
  }

  bool? tbOnMouseUp(int crossPos, MouseButton button, V2 mousePos) {
    return _tbForEach((wd, icon, mainPos) => icon.onMouseUp(V2.fromMC(mainPos, crossPos), wd.size, button, mousePos));
  }


  bool isOnCrossEdge(int crossPos, V2 mousePos) {
    var crossPos2 = crossPos + crossSize;
    if (!isColumns) crossPos2 += _conf.windowTitleBar.height;
    return (mousePos.cross - crossPos2).abs() <= BeansWindowManager.dragAcceptBoundary;
  }

  int? mainEdge(int crossPos, V2 mousePos) {
    if (!isColumns) crossPos += _conf.windowTitleBar.height;
    return _forEachWithMainPos((wd, mainPos) {
      final mainPos2 = mainPos + wd.size.main;
      final crossPos2 = crossPos + wd.size.cross;
      if (
        mousePos.cross >= crossPos &&
        mousePos.cross < crossPos2 &&
        (mousePos.main - mainPos2).abs() <= BeansWindowManager.dragAcceptBoundary
      ) {
        return windows.indexOf(wd);
      }
    });
  }

  int? getMainPos(WindowData test) {
    return _forEachWithMainPos((wd, mainPos) => wd == test ? mainPos : null);
  }

  /// breaks if [cb] returns a non-null value
  T? _forEachWithMainPos<T>(T? Function(WindowData, int) cb) {
    var mainPos = isColumns ? _conf.windowTitleBar.height : 0;
    for (var wd in windows) {
      final res = cb(wd, mainPos);
      if (res != null) return res;

      mainPos += isColumns ? wd.size.y : wd.size.x;
      if (isColumns) mainPos += _conf.windowTitleBar.height;
    }
  }

  void render(BeansRenderWindow rw, int crossPos, [WindowData? dontRender]) {
    _forEachWithMainPos((wd, mainPos) {
      if (wd == dontRender) return;
      final pos = V2.fromMC(mainPos, crossPos);
      BeansWindowManager.renderOrError(rw, wd, pos, true); 
    });
  }

  WindowData? hitTest(V2 hit, int crossPos, [bool withTitlebar = false]) {
    return _forEachWithMainPos((wd, mainPos) {
      final pos = V2.fromMC(mainPos, crossPos);
      bool res;
      if (withTitlebar) {
        res = wd.hitTestWithTitleBar(pos, hit);
      } else {
        res = wd.hitTest(pos, hit);
      }

      if (res) return wd;
    });
  }

}