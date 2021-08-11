import 'BeansWindow.dart';
import 'FontCache.dart';
import 'dart_codegen.dart';
import 'BeansRenderer.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'ColourWindow.dart';
import 'dart:math';

extension on Iterable<int> {
  int sum() {
    return isEmpty ? 0 : reduce((value, element) => value + element);
  }
}

/// WindowData represents metadata about a [BeansWindow], needed by the [BeansWindowManager].
class WindowData {
  int width;
  int height;
  bool isFocused;
  bool isFloating;
  BeansWindow window;

  /// Tests if the event at ([hitX], [hitY]) occured inside this window.
  /// [hitTest] is *inclusive* on the left/top and *exclusive* on the right/bottom.
  bool hitTest(int x, int y, int hitX, int hitY) {
    return (
      hitX >= x &&
      hitY >= y &&
      hitX < x2(x) &&
      hitY < y2(y)
    );
  }

  /// Render [window] using [x], [y], [width] and [height].
  void render(RenderWindow rw, int x, int y) {
    window.render(rw, x, y, width, height);
  }

  int x2(int x) => x + width;
  int y2(int y) => y + height;

  WindowData({
    required this.width,
    required this.height,
    required this.isFocused,
    required this.isFloating,
    required this.window
  });
}

// todo: instead of giving the [WindowData] width & height, give the Collection a crossSize and a list of mainSizes,
// and only calculate the width & height at render time. That way, to resize the collection, you only need to change
// one variable. Also, you can make windows private, and have a
// single method Collection.addWindow(BeansWindow win, int mainSize, bool isFocused)
//
/// A row or column of windows
class Collection {
  final windows = <WindowData>[];

  bool get isColumns => BeansWindowManager.layoutMode == BeansWindowLayoutMode.Columns;

  int x(int mainPos, int crossPos) => isColumns ? crossPos : mainPos;
  int y(int mainPos, int crossPos) => isColumns ? mainPos : crossPos;

  void setCrossSize(int newCrossSize) {
    for (var wd in windows) {
      if (isColumns) {
        wd.width = newCrossSize;
      } else {
        wd.height = newCrossSize;
      }
    }
  }

  /// quits if [cb] returns `true`
  void _forEachWithMainPos(bool? Function(WindowData, int) cb) {
    var mainPos = 0;
    for (var wd in windows) {
      if (cb(wd, mainPos) == true) return;

      mainPos += isColumns ? wd.height : wd.width;
    }
  }

  void render(RenderWindow rw, int crossPos) {
    _forEachWithMainPos((wd, mainPos) {
      wd.render(
        rw,
        x(mainPos, crossPos),
        y(mainPos, crossPos)
      );
    });
  }

  WindowData? hitTest(int hitX, int hitY, int crossPos) {
    WindowData? out;
    _forEachWithMainPos((wd, mainPos) {
      if (
        wd.hitTest(
          x(mainPos, crossPos),
          y(mainPos, crossPos),
          hitX,
          hitY
        )
      ) {
        out = wd;
        return true;
      }
    });
    return out;
  }

}

/// How new windows, snapping, & layout should align
enum BeansWindowLayoutMode {
  Columns,
  Rows
}

// todo:
//   - Replace all uses of idx with the actual candidate - they're mutable
//   - Create a class for a collection & calculate window positions dynamically - this gets rid of the rounding error
//     where windows would be 1 or 2 pixels too small.
//   - Decorations (needs text rendering)
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

  final List<Collection> _windows = [];
  
  int get _windowCount => _windows.map((collection) => collection.windows.length).sum();

  /// Iterate over each window in _windows. [cb] should return true as a kind of break statement - this facilitates
  /// breaking out of both loops at the same time.
  void _forEachWindow(bool? Function(WindowData) cb) {
    for (var collection in _windows) {
      for (var window in collection.windows) {
        if (cb(window) == true) return;
      }
    }
  }

  void _forEachCollectionWithCrossPos(bool? Function(Collection, int) cb) {
    var crossPos = 0;
    for (var collection in _windows) {
      if (cb(collection, crossPos) == true) return;

      crossPos += crossSize(collection.windows.last);
    }
  }

  final List<BeansWindow> _testWindows = [];

  static BeansWindowLayoutMode layoutMode = BeansWindowLayoutMode.Rows;

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
      ColourWindow(
        minWidth: 69,
        minHeight: 150,
        r: 255,
        g: 0,
        b: 0,
        onClick: addNextTest
      ),
      ColourWindow(
        minWidth: 500,
        minHeight: 250,
        r: 66,
        g: 22,
        b: 120,
        onClick: addNextTest
      ),
      ColourWindow(
        minWidth: 100,
        minHeight: 600,
        r: 255,
        g: 255,
        b: 0,
        onClick: addNextTest
      ),
      ColourWindow(
        minWidth: 1500,
        minHeight: 50,
        r: 0,
        g: 255,
        b: 0,
        onClick: addNextTest
      ),
      ColourWindow(
        minWidth: 100,
        minHeight: 900,
        r: 0,
        g: 255,
        b: 255,
        onClick: addNextTest
      )
    ]);
    addNextTest();
  }

  void addNextTest() {
    if (_windowCount < _testWindows.length) {
      print('adding new test window!');
      addWindow(_testWindows[_windowCount]);
    }
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
  int minPossibleMainSize(Collection collection) {
    return collection.windows.map((wd) => minMainSize(wd.window)).sum().toInt();
  }

  /// for a column: finds the window with the largest `minWidth`.
  int minPossibleCrossSize(Collection collection) {
    return minCrossSize(collection.windows.reduce((value, element) => minCrossSize(value.window) > minCrossSize(element.window) ? value : element).window);
  }

  /// get the current total main axis size of the collection
  int totalMainAxisSize(/*Collection collection*/) {
    // 2 ways of doing it
    _rw.GetSize(_x, _y);
    return isColumns ? _y.value : _x.value;
    //return collection.windows.map((wd) => mainSize(wd)).sum().toInt();
  }

  /// get the total cross axis size of the [RenderWindow]
  int totalCrossAxisSize() {
    _rw.GetSize(_x, _y);
    return isColumns ? _x.value : _y.value;
  }

/*
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
*/

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
/*
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
*/

  /// Calculates x, y, width, height and initializes the [WindowData]. Assumes that resizing of other windows
  /// has already been done, and that it is **not** a floating window.
  void addWindowToCollection(BeansWindow win, int collectionIdx, {required int mainSize_, required int crossSize_, bool focus = true}) {
    final collection = _windows[collectionIdx];
    collection.windows.add(
      WindowData(
        width: isColumns ? crossSize_ : mainSize_,
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
    final totalCrossSize = totalCrossAxisSize();
    var sum = 0;
    for (var i=0; i<_windows.length; i++) {
      if (i == collectionIdx) {
        sum += newCrossSize;
      } else {
        sum += minPossibleCrossSize(_windows[i]);
      }
    }
    return sum > totalCrossSize;
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
    final oldCrossSize = collection.windows.isEmpty ? 0 : crossSize(collection.windows.last);
    // ratio to reduce/increase the size of all other collections by.
    //! this must be a double
    final ratio = (totalCrossSize - (newCrossSize - oldCrossSize)) / totalCrossSize;

    Collection? previousCollection;
    for (var i=0; i<_windows.length; i++) {
      final modifyCollection = _windows[i];
      if (i == collectionIdx) {
        // resize the selected collection to newCrossSize
        //resizeCollection(i, newCrossSize);
        _windows[i].setCrossSize(newCrossSize);
      } else {
        // resize the collection to either its current size * the ratio, or its mininum size, whichever is bigger.
        _windows[i].setCrossSize(
          max(
            (crossSize(modifyCollection.windows.last) * ratio).toInt(),
            minPossibleCrossSize(modifyCollection)
          )
        );
        /*resizeCollection(i,
          max(
            (crossSize(modifyCollection.last) * ratio).toInt(),
            minPossibleCrossSize(modifyCollection)
          )
        );*/
      }
      // reposition the collection
      //setCollectionPos(i, previousCollection == null ? 0 : alignedEnd(previousCollection.last));
      previousCollection = modifyCollection;
    }

  }

  /// If the window's [minCrossSize] is smaller than the collection's [crossSize], resize the collection to accommodate the
  /// window. Assumes that doing so won't overflow the layout.
  void resizeIfNeeded(int collectionIdx, BeansWindow win) {
    final collection = _windows[collectionIdx];
    if (minCrossSize(win) > crossSize(collection.windows.last)) {
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
    final aNeedsResize = minCrossSize(win) > crossSize(candA.windows.last);
    final bNeedsResize = minCrossSize(win) > crossSize(candB.windows.last);
    if (aNeedsResize && bNeedsResize) {
      // smallest resize wins
      final aResize = crossSize(candA.windows.last) - minCrossSize(win);
      final bResize = crossSize(candB.windows.last) - minCrossSize(win);
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
    final aFreeSpace = mainSize(candA.windows.last) - minMainSize(candA.windows.last.window);
    final bFreeSpace = mainSize(candB.windows.last) - minMainSize(candB.windows.last.window);

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
    final gap = mainSize(collection.windows.last) - (minMainSize(collection.windows.last.window) + minMainSize(win));
    /// resize the current final window
    setMainSize(collection.windows.last, minMainSize(collection.windows.last.window) + (gap ~/ 2));
    resizeIfNeeded(collectionIdx, win);
    addWindowToCollection(
      win,
      collectionIdx,
      /*mainPos: offsetEnd(collection.last),
      crossPos: alignedStart(collection.last),*/
      mainSize_: minMainSize(win) + (gap ~/ 2),
      crossSize_: crossSize(collection.windows.last)
    );
  }

  /// Add a window to a collection using State 2 rules. Assumes that there is enough space, and that this won't cause the
  /// layout to overflow.
  void addState2(BeansWindow win, int collectionIdx) {
    final collection = _windows[collectionIdx];
    final currentMainSize = totalMainAxisSize();
    //! must be a double
    final ratio = (currentMainSize - minMainSize(win)) / currentMainSize;
    WindowData? previousWindow;
    for (var modifyWindow in collection.windows) {
      setMainSize(modifyWindow,
        max(
          (mainSize(modifyWindow) * ratio).toInt(),
          minMainSize(modifyWindow.window)
        )
      );
      //setMainPos(modifyWindow, previousWindow == null ? 0 : offsetEnd(previousWindow));
      previousWindow = modifyWindow;
    }
    resizeIfNeeded(collectionIdx, win);
    addWindowToCollection(
      win,
      collectionIdx,
      /*mainPos: offsetEnd(collection.last),
      crossPos: alignedStart(collection.last),*/
      mainSize_: minMainSize(win),
      crossSize_: crossSize(collection.windows.last)
    );
  }

  /// Create a new collection and add the window to it using State 3 rules. Assumes that doing so won't overflow the layout.
  void addState3(BeansWindow win) {
    final totalMainSize = totalMainAxisSize();
    final totalCrossSize = totalCrossAxisSize();
    
    final currentTotalMinCrossSize = _windows.map((collection) => minPossibleCrossSize(collection)).sum();
    // gap between all the current collections at their minPossibleCrossSize and this window at its minCrossSize
    final gap = totalCrossSize - (currentTotalMinCrossSize + minCrossSize(win));
    final crossSize_ = minCrossSize(win) + (gap ~/ 2);

    final previousCollection = _windows.isEmpty ? null : _windows.last;

    _windows.add(Collection());

    resizeCollections(_windows.length - 1, crossSize_);
    addWindowToCollection(
      win,
      _windows.length - 1,
      /*mainPos: 0,
      crossPos: previousCollection == null ? 0 : alignedEnd(previousCollection.last),*/
      mainSize_: totalMainSize,
      crossSize_: previousCollection == null ? totalCrossSize : crossSize_
    );
  }

  /// Display an error message telling the user that there is not enough space to create the window.
  void state4(String windowTitle) {

  }

  /// Display a popup informing the user of an *internal* Beans error. Maybe also log the error? idk.
  void error(String msg) {
    print(msg);
  }

  /// Something has gone seriously wrong, but the RenderWindow is still alive, so display a graphical panic screen.
  void gpanic(Object exception, StackTrace trace) {
    print('An exception occured within Beans:\n$exception\nTrace:\n$trace');
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
  /// - STATE 3: Add a new collection at the end of the layout. The cross size is the [RenderWindow]'s maximum possible
  /// cross size. The main size is halfway between the new window's [minMainSize] and the [minPossibleMainSize] of all the
  /// collections so far.
  /// - STATE 4: Display an error message.
  void addWindow(BeansWindow win) {
    //print('addWindow: ${win.title}');

    _rw.GetSize(_x, _y);
    if (
      win.minWidth > _x.value ||
      win.minHeight > _y.value
    ) {
      error('Window ${win.title} had out-of-bounds minimum size: (${win.minWidth}x${win.minHeight}) in a (${_x.value}x${_y.value}) window.');
      return;
    }

    final candidates = <int>[];
    int? selection;

    //* CHECK FOR STATE 1 CANDIDATES
    for (var i=0; i<_windows.length; i++) {
      final candidate = _windows[i];
      if (
        // it will be able to fit in at the end by resizing ONLY the final window
        (
          mainSize(candidate.windows.last) >= (
            minMainSize(candidate.windows.last.window) +
            minMainSize(win)
          )
        ) &&
        (
          // EITHER it doesn't need a resize
          (
            minCrossSize(win) <= crossSize(candidate.windows.last)
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
      print('state 1!!');
      addState1(win, selection);
      return;
    }

    //* CHECK FOR STATE 2 CANDIDATES
    for (var i=0; i<_windows.length; i++) {
      final candidate = _windows[i];
      if (
        // It will be able to fit into the collection if all windows are resized
        (
          totalMainAxisSize() >= (
            minPossibleMainSize(candidate) +
            minMainSize(win)
          )
        ) &&
        // Same as state 1
        (
          (
            minCrossSize(win) <= crossSize(candidate.windows.last)
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
      print('state 2!!');
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
      print('state 3!!');
      addState3(win);
      return;
    }
    
    print('state 4!!');
    state4(win.title);

  }

  /// Starts the event loop.
  void start() {
    try {
      _ren.run();
    } catch (e, trace) {
      gpanic(e, trace);
    }
  }

  /// Destroys any memory that has been allocated
  void destroy() {
    _ren.destroy();
  }

  WindowData? get _focusedWindow {
    WindowData? out;
    _forEachWindow((wd) {
      if (wd.isFocused) {
        out = wd;
        // assume there's only one focused window at a time
        return true;
      }
    });
    
    return out;
  }

  /*void _render(RenderWindow rw) {
    // todo: decorations etc
    _forEachWindow((wd) {
      // todo: if an error occurs during the render, display it in place of the window
      wd.window.render(
        rw,
        wd.x,
        wd.y,
        wd.width,
        wd.height
      );
    });
    final font = FontCache.family().font();
    rw.DrawText(font.structPointer, 'DEEZ NUTSSSSSSS', 15, 15, 0, 0, 0, 255);
  }*/

  /// Render all windows.
  /// 
  /// Each window's x pos, y pos, width & height are updated to account for rounding issues during [addWindow].
  void _render(RenderWindow rw) {
    _forEachCollectionWithCrossPos((collection, crossPos) {
      collection.render(rw, crossPos);
    });
    final font = FontCache.family().font();
    rw.DrawText(font, 'DEEZ NUTSSSSSSS', 15, 15, 0, 0, 0, 255);
  }

  /// update the focused window based on [_x] and [_y]
  /*void _setFocusedWindow() {
    if (!(_focusedWindow?.hitTest(_x.value, _y.value) ?? false)) {
      _focusedWindow?.isFocused = false;
      _forEachWindow((wd) {
        if (wd.hitTest(_x.value, _y.value)) {
          wd.isFocused = true;
          return true;
        }
      });
    }
  }*/
  void _setFocusedWindow() {
    _forEachCollectionWithCrossPos((collection, crossPos) {
      final wd = collection.hitTest(_x.value, _y.value, crossPos);
      if (wd != null) {
        wd.isFocused = true;
        return true;
      }
    });
  }

  void _event(Event event) {
    switch (event.type) {
      case SDLEventType.KeyDown: {
        _focusedWindow?.window.onKeyDown(event.GetKeyPressReleaseData());
        break;
      }

      case SDLEventType.MouseMove: {
        event.GetMouseMoveData(_x, _y);

        _focusedWindow?.window.onMouseMove(_x.value, _y.value);
        break;
      }

      case SDLEventType.MouseDown: {
        final button = event.GetMousePressReleaseData(_x, _y);
        _setFocusedWindow();

        if (button == MouseButton.Right) {
          _ren.quit();
        }
        
        _focusedWindow?.window.onMouseDown(_x.value, _y.value, button);
        break;
      }

      default: {}
    }
  }
}