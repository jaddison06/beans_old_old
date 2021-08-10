import 'dart:html';

import 'BeansWindow.dart';
import 'dart_codegen.dart';
import 'BeansRenderer.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'ColourWindow.dart';
import 'dart:math';

extension on Iterable<num> {
  num sum() {
    return reduce((value, element) => value + element);
  }
}

/// WindowData represents metadata about a [BeansWindow], needed by the [BeansWindowManager].
class WindowData {
  int x;
  int y;
  int width;
  int height;
  bool isFocused;
  bool isFloating;
  BeansWindow window;

  /// Tests if the event at (x, y) occured inside this window.
  /// [hitTest] is *inclusive* on the left/top and *exclusive* on the right/bottom.
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
/// - Rendering [BeansWindow]s
/// - Turning the raw [Event]s from SDL into a more usable format
/// - Hit-testing windows and passing these events to them
/// - Allowing the user to resize, relocate, add, or remove windows
/// - Rendering window decorations and other UI elements
class BeansWindowManager {
  late final BeansRenderer _ren;
  final RenderWindow _rw;

  final Pointer<Int32> _x;
  final Pointer<Int32> _y;

  final List<List<WindowData>> _windows = [];
  
  List<WindowData> _allWindows() => _windows.reduce((value, element) => value..addAll(element));

  final List<BeansWindow> _testWindows = [];

  final layoutMode = BeansWindowLayoutMode.Rows;

  String? panicMsg;

  BeansWindowManager(this._rw) :
    _x = malloc<Int32>(),
    _y = malloc<Int32>()
  {
    _ren = BeansRenderer(
      rw: _rw,
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


  /// for a column: if every window in the column was at `minHeight`, how tall would the whole thing be?
  int minPossibleMainSize(List<WindowData> collection) {
    return collection.map((wd) => minMainSize(wd.window)).sum().toInt();
  }

  /// for a column: finds the window with the largest `minWidth`.
  int minPossibleCrossSize(List<WindowData> collection) {
    return minCrossSize(collection.reduce((value, element) => minCrossSize(value.window) > minCrossSize(element.window) ? value : element).window);
  }

  /// get the current total main axis size of the collection
  int totalMainAxisSize(List<WindowData> collection) {
    // 2 ways of doing it
    //_rw.GetSize(_x, _y);
    //return isColumns ? _y.value : _x.value;
    return collection.map((wd) => mainSize(wd)).sum().toInt();
  }

  /// get the total cross axis size of the [RenderWindow]
  int totalCrossAxisSize() {
    _rw.GetSize(_x, _y);
    return isColumns ? _x.value : _y.value;
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


  /// set the main axis size of a window
  void setMainSize(WindowData wd, int newSize) {
    if (isColumns) {
      wd.height = newSize;
    } else {
      wd.width = newSize;
    }
  }

  /// set the cross axis size of a window
  void setCrossSize(WindowData wd, int newSize) {
    if (isColumns) {
      wd.width = newSize;
    } else {
      wd.height = newSize;
    }
  }

  /// set the position of a window on the main axis
  void setMainPos(WindowData wd, int newPos) {
    if (isColumns) {
      wd.y = newPos;
    } else {
      wd.x = newPos;
    }
  }

  /// set the position of a window on the cross axis
  void setCrossPos(WindowData wd, int newPos) {
    if (isColumns) {
      wd.x = newPos;
    } else {
      wd.y = newPos;
    }
  }


  /// change the cross axis size of a whole collection
  void resizeCollection(int collectionIdx, int newCrossSize) {
    for (var wd in _windows[collectionIdx]) {
      setCrossSize(wd, newCrossSize);
    }
  }

  /// change the cross axis position of a whole collection
  void setCollectionPos(int collectionIdx, int newCrossPos) {
    for (var wd in _windows[collectionIdx]) {
      setCrossPos(wd, newCrossPos);
    }
  }


  /// does setup for the [WindowData]. assumes that resizing of other windows has already been done.
  /// assumes it is **not** a floating window, and that [mainSize_] is valid.
  void addWindowToCollection(BeansWindow win, int collectionIdx, int mainSize_, {bool focus = true}) {

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

  /// Check if resizing the collection at [collectionIdx] to [newCrossSize] would cause the layout to overflow.
  bool wouldOverflow(int collectionIdx, int newCrossSize) {
    final totalMainSize = totalMainAxisSize(_windows.last);
    var sum = 0;
    for (int i=0; i<_windows.length; i++) {
      if (i == collectionIdx) {
        sum += newCrossSize;
      } else {
        sum += minPossibleCrossSize(_windows[i]);
      }
    }
    return sum > totalMainSize;
  }

  /// Resize all collections so that the collection at [collectionIdx] has a crossSize of [newCrossSize].
  /// 
  /// Similarly to [addState2], all other collections are scaled so that either they're at the same size relative to each
  /// other, or they're at their minimum size. Assumes that doing so won't overflow the layout.
  void resizeCollections(int collectionIdx, int newCrossSize) {
    // total cross axis size of the whole layout
    final totalCrossSize = totalCrossAxisSize();
    final collection = _windows[collectionIdx];
    // previous crossSize of the collection
    final oldCrossSize = collection.isEmpty ? 0 : crossSize(collection.last);
    // ratio to reduce/increase the size of all other collections by.
    //! this must be a double
    final ratio = (totalCrossSize - (newCrossSize - oldCrossSize)) / totalCrossSize;

    List<WindowData>? previousCollection;
    for (var i=0; i<_windows.length; i++) {
      final modifyCollection = _windows[i];
      if (i == collectionIdx) {
        // resize the selected collection to newCrossSize
        resizeCollection(i, newCrossSize);
      } else {
        // resize the collection to either its current size * the ratio, or its mininum size, whichever is bigger.
        resizeCollection(i,
          max(
            (crossSize(modifyCollection.last) * ratio).toInt(),
            minPossibleCrossSize(modifyCollection)
          )
        );
      }
      // reposition the collection
      setCollectionPos(i, previousCollection == null ? 0 : alignedEnd(previousCollection.last));
      previousCollection = modifyCollection;
    }

  }

  /// If the window's [minCrossSize] is smaller than the collection's [crossSize], resize the collection to accommodate the
  /// window. Assumes that doing so won't overflow the layout.
  void resizeIfNeeded(int collectionIdx, BeansWindow win) {
    final collection = _windows[collectionIdx];
    if (minCrossSize(win) > crossSize(collection.last)) {
      resizeCollections(collectionIdx, minCrossSize(win));
    }
  }

  /// Get the best candidate collection for State 1 or 2, based on the amount of resizing needed.
  /// 
  /// Returns `null` if the result is inconclusive - a specific discriminator should then be used to determine the winner.
  /// - If only one window needs a resize, then the other one wins.
  /// - If both windows need a resize, the winner is the one with the smallest resize, or inconclusive if they are equal.
  /// - If neither needs a resize, the result is inconclusive.
  int? bestState1Or2Candidate(BeansWindow win, int a, int b) {
    final candA = _windows[a];
    final candB = _windows[b];
    final aNeedsResize = minCrossSize(win) > crossSize(candA.last);
    final bNeedsResize = minCrossSize(win) > crossSize(candB.last);
    if (aNeedsResize && bNeedsResize) {
      // smallest resize wins
      final aResize = crossSize(candA.last) - minCrossSize(win);
      final bResize = crossSize(candB.last) - minCrossSize(win);
      if (aResize > bResize) {
        return a;
      } else if (bResize > aResize) {
        return b;
      } else {
        // both need an equal resize
        return null;
      }
    } else if (!aNeedsResize && bNeedsResize) {
      return a;
    } else if (aNeedsResize && !bNeedsResize) {
      return b;
    } else {
      // inconclusive
      return null;
    }
  }

  /// Get the best candidate collection for State 1.
  /// 
  /// [bestState1Or2Candidate] is used initially. If this is inconclusive, the most spacious collection is used.
  int bestState1Candidate(BeansWindow win, int a, int b) {
    final resizeBest = bestState1Or2Candidate(win, a, b);
    if (resizeBest != null) {
      return resizeBest;
    }

    final candA = _windows[a];
    final candB = _windows[b];
    final aFreeSpace = mainSize(candA.last) - minMainSize(candA.last.window);
    final bFreeSpace = mainSize(candB.last) - minMainSize(candB.last.window);

    if (aFreeSpace > bFreeSpace) {
      return a;
    } else {
      // ok yeah so if they're equal b will get chosen
      return b;
    }
  }

  /// Get the best candidate collection for State 2
  /// 
  /// [bestState1Or2Candidate] is used initially. If this is inconclusive, the collection with the largest
  /// [minPossibleMainSize], ie the one which will be squashed the least, is used.
  int bestState2Candidate(BeansWindow win, int a, int b) {
    final resizeBest = bestState1Or2Candidate(win, a, b);
    if (resizeBest != null) {
      return resizeBest;
    }

    final candA = _windows[a];
    final candB = _windows[b];
    if (minPossibleMainSize(candA) > minPossibleMainSize(candB)) {
      return a;
    } else {
      // again, if they're equal b will be returned
      return b;
    }
  }

  /// Add a window to a collection using State 1 rules. Assumes that there is enough space, and that this won't cause the
  /// layout to overflow.
  void addState1(BeansWindow win, int collectionIdx) {
    final collection = _windows[collectionIdx];
    // Gap between the two windows if they were both at their minMainSize
    final gap = mainSize(collection.last) - (minMainSize(collection.last.window) + minMainSize(win));
    /// resize the current final window
    setMainSize(collection.last, minMainSize(collection.last.window) + (gap ~/ 2));
    resizeIfNeeded(collectionIdx, win);
    addWindowToCollection(win, collectionIdx, minMainSize(win) + (gap ~/ 2));
  }

  /// Add a window to a collection using State 2 rules. Assumes that there is enough space, and that this won't cause the
  /// layout to overflow.
  void addState2(BeansWindow win, int collectionIdx) {
    final collection = _windows[collectionIdx];
    final currentMainSize = totalMainAxisSize(collection);
    //! must be a double
    final ratio = (currentMainSize - minMainSize(win)) / currentMainSize;
    WindowData? previousWindow;
    for (var modifyWindow in collection) {
      setMainSize(modifyWindow,
        max(
          (mainSize(modifyWindow) * ratio).toInt(),
          minMainSize(modifyWindow.window)
        )
      );
      setMainPos(modifyWindow, previousWindow == null ? 0 : offsetEnd(previousWindow));
      previousWindow = modifyWindow;
    }
    resizeIfNeeded(collectionIdx, win);
    addWindowToCollection(win, collectionIdx, minMainSize(win));
  }

  /// Create a new collection and add the window to it using State 3 rules. Assumes that doing so won't overflow the layout.
  void addState3(BeansWindow win) {
    final totalMainSize = totalMainAxisSize(_windows.last);
    _windows.add(<WindowData>[]);
    resizeCollections(_windows.length, minCrossSize(win));
    addWindowToCollection(win, _windows.length, totalMainSize);
  }

  /// Display an error message telling the user that there is not enough space to create the window.
  void state4(String windowTitle) {

  }

  /// Adds a [BeansWindow] to the layout
  /// 
  /// logic:
  /// - STATE 1: Add the window to the end of an existing collection. In the main axis, resize **only** the last window, to
  /// halfway between its minimum size and that of the new window. In the cross axis, only resize the collection if the new
  /// window requires it - this is undesirable.
  /// - STATE 2: Add the window to the end of an existing collection. In the main axis, scale all the windows in the collection
  /// so that they keep their relative size, or hit their minimum. In the cross axis, only resize the collection if the new
  /// window requires it - this is undesirable.
  /// - STATE 3: Add a new collection at the end of the layout with a mainSize of the window's [minMainSize] and a cross size
  /// of the [RenderWindow]'s maximum possible cross size.
  /// - STATE 4: Display an error message.
  void addWindow(BeansWindow win) {
    final candidates = <int>[];
    int? selection;

    //* CHECK FOR STATE 1 CANDIDATES
    for (var i=0; i<_windows.length; i++) {
      final candidate = _windows[i];
      if (
        // it will be able to fit in at the end by resizing ONLY the final window
        (
          mainSize(candidate.last) >= (
            minMainSize(candidate.last.window) +
            minMainSize(win)
          )
        ) &&
        (
          // EITHER it doesn't need a resize
          (
            minCrossSize(win) <= crossSize(candidate.last)
          ) ||
          // OR it does need a resize, but the resize wouldn't cause a layout overflow.
          (
            !wouldOverflow(i, minCrossSize(win))
          )
        )
      ) {
        candidates.add(i);
      }
    }

    if (candidates.length == 1) {
      selection = candidates.first;
    } else if (candidates.length > 1) {
      selection = candidates.reduce((a, b) => bestState1Candidate(win, a, b));
    }

    // did we find a suitable candidate for State 1?
    if (selection != null) {
      addState1(win, selection);
      return;
    }

    //* CHECK FOR STATE 2 CANDIDATES
    for (var i=0; i<_windows.length; i++) {
      final candidate = _windows[i];
      if (
        // It will be able to fit into the collection if all windows are resized
        (
          totalMainAxisSize(candidate) >= (
            minPossibleMainSize(candidate) +
            minMainSize(win)
          )
        ) &&
        // Same as state 1
        (
          (
            minCrossSize(win) <= crossSize(candidate.last)
          ) ||
          (
            !wouldOverflow(i, minCrossSize(win))
          )
        )
      ) {
        candidates.add(i);
      }
    }

    if (candidates.length == 1) {
      selection = candidates.first;
    } else if (candidates.length > 1) {
      selection = candidates.reduce((a, b) => bestState2Candidate(win, a, b));
    }

    // did we find a suitable candidate for State 2?
    if (selection != null) {
      addState2(win, selection);
      return;
    }

    //* CHECK IF STATE 3 IS APPLICABLE
    if (
      // a new collection with a cross size of the window's minCrossSize will fit into the layout
      totalCrossAxisSize() >= (
        _windows.map((collection) => minPossibleCrossSize(collection)).sum() +
        minCrossSize(win)
      )
    ) {
      addState3(win);
      return;
    }

    state4(win.title);

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
    // todo: decorations etc
    for (var win in _allWindows()) {
      // todo: if an error occurs during the render, display it in place of the window
      win.window.render(
        rw,
        win.x,
        win.y,
        win.width,
        win.height
      );
    }
  }

  /// update the focused window based on [_x] and [_y]
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