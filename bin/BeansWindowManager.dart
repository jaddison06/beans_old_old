import 'BeansWindow.dart';
import 'dart_codegen.dart';
import 'BeansRenderer.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'ColourWindow.dart';

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

  int get x2 => x + width;
  int get y2 => y + height;

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

/// How new windows, snapping, & layout should align
enum BeansWindowLayoutMode {
  Columns,
  Rows
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

  final List<List<WindowData>> _windows = [];
  
  List<WindowData> _allWindows() => _windows.reduce((value, element) => value..addAll(element));

  final List<BeansWindow> _testWindows = [];

  final layoutMode = BeansWindowLayoutMode.Rows;

  String? panicMsg;

  BeansWindowManager(RenderWindow rw) :
    _x = malloc<Int32>(),
    _y = malloc<Int32>()
  {
    _ren = BeansRenderer(
      rw: rw,
      render: _render,
      event: _event
    );
    _testWindows.addAll([
      
    ]);
  }

  /// get minimum main axis size of the window
  int minMainSize (BeansWindow win) => isColumns ? win.minHeight : win.minWidth;
  /// get minimum cross axis size of the window
  int minCrossSize(BeansWindow win) => isColumns ? win.minWidth : win.minHeight;

  /// get current main axis size of the window
  int mainSize (WindowData wd) => isColumns ? wd.height : wd.width;
  /// get current cross axis size of the window
  int crossSize(WindowData wd) => isColumns ? wd.width : wd.height;

  /// for a column: finds the window with the largest minWidth.
  int minCrossAxisSize(List<WindowData> collection) {
    return minCrossSize(collection.reduce((value, element) => minCrossSize(value.window) > minCrossSize(element.window) ? value : element).window);
  }

  /// for a column: if every window in the column was at minHeight, how tall would the whole thing be?
  int minPossibleSize(List<WindowData> collection) {
    return collection.map((wd) => minMainSize(wd.window)).reduce((value, element) => value + element);
  }

  /// for a column, the X position of the window's left edge.
  int alignedStart(WindowData wd) {
    return isColumns ? wd.x : wd.y;
  }

  /// for a column, the Y position of the window's top edge.
  int offsetStart(WindowData wd) {
    return isColumns ? wd.y : wd.x;
  }

  /// for a column, the X position of the window's right edge.
  int alignedEnd(WindowData wd) {
    // 2 ways of doing it
    //return isColumns ? wd.x2 : wd.y2;
    return alignedStart(wd) + crossSize(wd);
  }

  /// for a column, the Y position of the window's bottom edge.
  int offsetEnd(WindowData wd) {
    return offsetStart(wd) + mainSize(wd);
  }

  void setMainSize(WindowData wd, int newSize) {
    if (isColumns) {
      wd.height = newSize;
    } else {
      wd.width = newSize;
    }
  }

  void setCrossSize(WindowData wd, int newSize) {
    if (isColumns) {
      wd.width = newSize;
    } else {
      wd.height = newSize;
    }
  }

  /// does setup for the WindowData. assumes that resizing of other windows has already been done.
  /// assumes it is **not** a floating window, and that the cross size is valid.
  void addToCollection(BeansWindow win, int collectionIdx, int mainSize_, {bool focus = true}) {

    final previous = _windows[collectionIdx].last;
    final mainPos = offsetEnd(previous);
    final crossPos = alignedStart(previous);
    final crossSize_ = crossSize(previous);

    _windows[collectionIdx].add(
      WindowData(
        x: isColumns ? crossPos : mainPos,
        y: isColumns ? mainPos : crossPos,
        width:  isColumns ? crossSize_ : mainSize_,
        height: isColumns ? mainSize_ : crossSize_,
        window: win,
        isFloating: false,
        isFocused: focus
      )
    );
  }

  bool get isColumns => layoutMode == BeansWindowLayoutMode.Columns;


  // TODO: somewhere in here we need to check whether the window's cross axis size would be bigger than that of the
  // target collection. idk if that should be part of STATE 1, or somewhere in between 1 & 2. Anyway, once all this
  // logic is implemented we can start putting some ColourWindows onscreen.
  //
  /// Adds a BeansWindow to the layout
  /// logic:
  /// - STATE 1: If it can be added to the end of a column/row by resizing the final window and *nothing else*, put it there. If there
  /// are multiple columns/rows to which this is applicable, choose the one with the most free space for the final window.
  /// - STATE 2: Otherwise, if it can be added to the end of a column/row by resizing all windows closer to their minimum size, do that.
  /// Same as above in that if there are multiple possibilities, the most spacious is chosen.
  /// - STATE 3: Otherwise, create a new column/row where the new window takes up the maximum size along the main axis. Resize all columns/rows
  /// so that their relative size remains the same, but the new window takes up a relatively even amount of space which is
  /// larger than its minimum.
  /// - STATE 4 (ERROR): Otherwise, display an error message to the user.
  void addWindow(BeansWindow window) {
    final candidates = <int>[];
    int? selectedCollection;

    // iterate over _windows to see if STATE 1 is applicable
    for (var i=0; i<_windows.length; i++) {
      final collection = _windows[i];
      if (
        // we can resize the last window in the main axis to fit this one in
        (mainSize(collection.last) - minMainSize(collection.last.window) > minMainSize(window)) &&
        // we won't have to change the cross size of the collection
        (crossSize(collection.last) >= minCrossSize(window))
      ) {
        candidates.add(i);
      }
    }

    if (candidates.length == 1) {
      // we found one suitable candidate - select it.
      selectedCollection = candidates.first;

    } else if (candidates.length > 1) {
      // multiple candidates found - iterate over them to find the most spacious
      var best = 0;
      for (var i=1; i<candidates.length; i++) {
        final bestCol = _windows[best];
        final compare = _windows[i];
        final bestDiff = mainSize(bestCol.last) - minMainSize(bestCol.last.window);
        final compareDiff = mainSize(compare.last) - minMainSize(compare.last.window);
        if (compareDiff > bestDiff) {
          best = i;
        }
      }
      selectedCollection = candidates[best];
    }

    if (selectedCollection != null) {
      // we found a STATE 1 collection!
      final modifying = _windows[selectedCollection].last;
      final gap = mainSize(modifying) - (minMainSize(modifying.window) + minMainSize(window));
      setMainSize(modifying, minMainSize(modifying.window) + (gap ~/ 2));
      addToCollection(
        window,
        selectedCollection,
        minMainSize(window) + (gap ~/ 2)
      );

      // we're done
      return;
    }

    // check for a STATE 2 collection
    for (var collection in _windows) {
      if (minPossibleSize(collection))
    }

  }

  /// Starts the event loop.
  void start() {
    _ren.run();
  }

  /// Destroys any memory that has been allocated
  void destroy() {
    _ren.destroy();
  }

  WindowData get _focusedWindow => _allWindows().where((wd) => wd.isFocused).first;

  void _render(RenderWindow rw) {
    // TODO: decorations etc
    for (var win in _allWindows()) {
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
      for (var win in _allWindows()) {
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