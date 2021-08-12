import 'BeansWindow.dart';
import 'dart_codegen.dart';
import 'BeansRenderer.dart';
import 'dart:ffi';
import 'ColourWindow.dart';
import 'dart:math';
import 'XYPointer.dart';
import 'BeansRenderWindow.dart';
import 'CatchAll.dart';

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
  void render(BeansRenderWindow rw, int x, int y) {
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

/// A row or column of windows
class Collection extends XYPointer with CatchAll {
  static int _instanceCount = 0;

  final int _id;

  Collection() :
    _id = _instanceCount {
      _instanceCount ++;
    }
  
  @override
  bool operator == (Object other) {
    if (other.runtimeType != Collection) return false;
    return (other as Collection)._id == _id;
  }

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

  void render(BeansRenderWindow rw, int crossPos) {
    _forEachWithMainPos((wd, mainPos) {
      final x_ = x(mainPos, crossPos);
      final y_ = y(mainPos, crossPos);
      catchAll(() {
        wd.render(
          rw,
          x_,
          y_
        );
      }, (e, trace) {
        rw.FillRectC(x_, y_, wd.width, wd.height, 255, 0, 0);
        final msg = 'Error while rendering window ${wd.window.title}:\n$e\nTraceback:\n$trace';
        rw.DrawText(msg, x_, y_, 0, 0, 0);
      });
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

/// BeansWindowManager is responsible for:
/// - Rendering [BeansWindow]s
/// - Turning the raw [Event]s from SDL into a more usable format
/// - Hit-testing windows and passing these events to them
/// - Allowing the user to resize, relocate, add, or remove windows
/// - Rendering window decorations and other UI elements
class BeansWindowManager extends XYPointer with CatchAll {
  late final BeansRenderer _ren;
  final BeansRenderWindow _rw;

  String? panicMsg;

  late final Image _forgor;

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

  BeansWindowManager(this._rw) {
    _ren = BeansRenderer(
      rw: _rw,
      render: _render,
      event: _event,
      onError: gpanic
    );

    _forgor = Image(_rw, 'res/forgor.jpg');

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
    _rw.GetSize(xPtr, yPtr);
    return isColumns ? yPtr.value : xPtr.value;
    //return collection.windows.map((wd) => mainSize(wd)).sum().toInt();
  }

  /// get the total cross axis size of the [BeansRenderWindow]
  int totalCrossAxisSize() {
    _rw.GetSize(xPtr, yPtr);
    return isColumns ? xPtr.value : yPtr.value;
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

  /// Calculates x, y, width, height and initializes the [WindowData]. Assumes that resizing of other windows
  /// has already been done, and that it is **not** a floating window.
  void addWindowToCollection(BeansWindow win, Collection collection, {required int mainSize_, required int crossSize_, bool focus = true}) {
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

  /// Check if resizing [collectionToResize] to [newCrossSize] would cause the layout to overflow.
  bool wouldOverflow(Collection collectionToResize, int newCrossSize) {
    final totalCrossSize = totalCrossAxisSize();
    var sum = 0;
    for (var collection in _windows) {
      if (collection == collectionToResize) {
        sum += newCrossSize;
      } else {
        sum += minPossibleCrossSize(collection);
      }
    }
    return sum > totalCrossSize;
  }

  /// Resize all collections so that [collection] has a crossSize of [newCrossSize].
  /// 
  /// Similarly to [addState2], all other collections are scaled so that either they're at the same size relative to each
  /// other, or they're at their minimum size. Assumes that doing so won't overflow the layout.
  void resizeCollections(Collection collection, int newCrossSize) {
    // total cross axis size of the whole layout
    final totalCrossSize = totalCrossAxisSize();
    // previous crossSize of the collection
    final oldCrossSize = collection.windows.isEmpty ? 0 : crossSize(collection.windows.last);
    // ratio to reduce/increase the size of all other collections by.
    //! this must be a double
    final ratio = (totalCrossSize - (newCrossSize - oldCrossSize)) / totalCrossSize;

    for (var modifyCollection in _windows) {
      if (modifyCollection == collection) {
        // resize the selected collection to newCrossSize
        modifyCollection.setCrossSize(newCrossSize);
      } else {
        // resize the collection to either its current size * the ratio, or its mininum size, whichever is bigger.
        modifyCollection.setCrossSize(
          max(
            (crossSize(modifyCollection.windows.last) * ratio).toInt(),
            minPossibleCrossSize(modifyCollection)
          )
        );
      }
    }

  }

  /// If the window's [minCrossSize] is smaller than the collection's [crossSize], resize the collection to accommodate the
  /// window. Assumes that doing so won't overflow the layout.
  void resizeIfNeeded(Collection collection, BeansWindow win) {
    if (minCrossSize(win) > crossSize(collection.windows.last)) {
      resizeCollections(collection, minCrossSize(win));
    }
  }

  /// Get the best candidate collection for State 1 or 2, based on the amount of resizing needed.
  /// 
  /// Returns `null` if the result is inconclusive - a specific discriminator should then be used to determine the winner.
  /// - If only one window needs a resize, then the other one wins.
  /// - If both windows need a resize, the winner is the one with the smallest resize, or inconclusive if they are equal.
  /// - If neither needs a resize, the result is inconclusive.
  Collection? bestState1Or2Candidate(BeansWindow win, Collection a, Collection b) {
    final aNeedsResize = minCrossSize(win) > crossSize(a.windows.last);
    final bNeedsResize = minCrossSize(win) > crossSize(b.windows.last);
    if (aNeedsResize && bNeedsResize) {
      // smallest resize wins
      final aResize = crossSize(a.windows.last) - minCrossSize(win);
      final bResize = crossSize(b.windows.last) - minCrossSize(win);
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
  Collection bestState1Candidate(BeansWindow win, Collection a, Collection b) {
    final resizeBest = bestState1Or2Candidate(win, a, b);
    if (resizeBest != null) {
      return resizeBest;
    }

    final aFreeSpace = mainSize(a.windows.last) - minMainSize(a.windows.last.window);
    final bFreeSpace = mainSize(b.windows.last) - minMainSize(b.windows.last.window);

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
  Collection bestState2Candidate(BeansWindow win, Collection a, Collection b) {
    final resizeBest = bestState1Or2Candidate(win, a, b);
    if (resizeBest != null) {
      return resizeBest;
    }

    if (minPossibleMainSize(a) > minPossibleMainSize(b)) {
      return a;
    } else {
      // again, if they're equal b will be returned
      return b;
    }
  }

  /// Add a window to a collection using State 1 rules. Assumes that there is enough space, and that this won't cause the
  /// layout to overflow.
  void addState1(BeansWindow win, Collection collection) {
    // Gap between the two windows if they were both at their minMainSize
    final gap = mainSize(collection.windows.last) - (minMainSize(collection.windows.last.window) + minMainSize(win));
    /// resize the current final window
    setMainSize(collection.windows.last, minMainSize(collection.windows.last.window) + (gap ~/ 2));
    resizeIfNeeded(collection, win);
    addWindowToCollection(
      win,
      collection,
      /*mainPos: offsetEnd(collection.last),
      crossPos: alignedStart(collection.last),*/
      mainSize_: minMainSize(win) + (gap ~/ 2),
      crossSize_: crossSize(collection.windows.last)
    );
  }

  /// Add a window to a collection using State 2 rules. Assumes that there is enough space, and that this won't cause the
  /// layout to overflow.
  void addState2(BeansWindow win, Collection collection) {
    final currentMainSize = totalMainAxisSize();
    //! must be a double
    final ratio = (currentMainSize - minMainSize(win)) / currentMainSize;
    for (var modifyWindow in collection.windows) {
      setMainSize(modifyWindow,
        max(
          (mainSize(modifyWindow) * ratio).toInt(),
          minMainSize(modifyWindow.window)
        )
      );
    }
    resizeIfNeeded(collection, win);
    addWindowToCollection(
      win,
      collection,
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

    resizeCollections(_windows.last, crossSize_);
    addWindowToCollection(
      win,
      _windows.last,
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

  /// Something has gone seriously wrong, but the BeansRenderWindow is still alive, so display a graphical panic screen.
  void gpanic(Object exception, StackTrace trace) {
    panicMsg = 'An exception occured within Beans:\n$exception\nTrace:\n$trace';
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
  /// - STATE 3: Add a new collection at the end of the layout. The cross size is the [BeansRenderWindow]'s maximum possible
  /// cross size. The main size is halfway between the new window's [minMainSize] and the [minPossibleMainSize] of all the
  /// collections so far.
  /// - STATE 4: Display an error message.
  void addWindow(BeansWindow win) {
    //print('addWindow: ${win.title}');

    _rw.GetSize(xPtr, yPtr);
    if (
      win.minWidth > xPtr.value ||
      win.minHeight > yPtr.value
    ) {
      error('Window ${win.title} had out-of-bounds minimum size: (${win.minWidth}x${win.minHeight}) in a (${xPtr.value}x${yPtr.value}) window.');
      return;
    }

    final candidates = <Collection>[];
    Collection? selection;

    //* CHECK FOR STATE 1 CANDIDATES
    for (var candidate in _windows) {
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
            !wouldOverflow(candidate, minCrossSize(win))
          )
        )
      ) {
        candidates.add(candidate);
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
    for (var candidate in _windows) {
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
            !wouldOverflow(candidate, minCrossSize(win))
          )
        )
      ) {
        candidates.add(candidate);
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
    _ren.run();
  }

  /// Destroys any memory that has been allocated
  @override
  void destroy() {
    _ren.destroy();
    for (var collection in _windows) {
      collection.destroy();
    }
    super.destroy();
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

  /// Render all windows.
  /// 
  /// Each window's x pos, y pos, width & height are updated to account for rounding issues during [addWindow].
  void _render(BeansRenderWindow rw) {
    if (panicMsg != null) {
      // If we're supposed to be panicking, then try and show the panic message.
      // But it's entirely possible that the reason we're panicking is because of a RenderWindow problem, meaning we can't render.
      // If that happens, we'll just enter an infinite loop, with _ren catching the exception and calling gpanic().
      // The solution is to catch our own exceptions while we're rendering the panic message, so if something has gone
      // that badly wrong we can tell the renderer to stop handling our error and just pass it up, which will lead to
      // Beans._panic() and a clean-ish program exit.
      catchAll(() {
        rw.DrawImage(_forgor, 0, 0);
        rw.DrawText(panicMsg!, 0, _forgor.height, 255, 0, 0);
      }, (e, trace) {
        _ren.handleErrors = false;
      });
      return;
    }
    throw Exception('Null check operator used on a null value');
    _forEachCollectionWithCrossPos((collection, crossPos) {
      collection.render(rw, crossPos);
    });
  }

  /// update the focused window based on [_x] and [_y]
  void _setFocusedWindow() {
    _forEachCollectionWithCrossPos((collection, crossPos) {
      final wd = collection.hitTest(xPtr.value, yPtr.value, crossPos);
      if (wd != null) {
        wd.isFocused = true;
        return true;
      }
    });
  }

  void _event(Event event) {
    switch (event.type) {
      case SDLEventType.Quit: {
        _ren.quit();
        break;
      }

      case SDLEventType.KeyDown: {
        _focusedWindow?.window.onKeyDown(event.GetKeyPressReleaseData());
        break;
      }

      case SDLEventType.MouseMove: {
        event.GetMouseMoveData(xPtr, yPtr);

        _focusedWindow?.window.onMouseMove(xPtr.value, yPtr.value);
        break;
      }

      case SDLEventType.MouseDown: {
        final button = event.GetMousePressReleaseData(xPtr, yPtr);
        _setFocusedWindow();

        if (button == MouseButton.Right) {
          _ren.quit();
        }
        
        _focusedWindow?.window.onMouseDown(xPtr.value, yPtr.value, button);
        break;
      }

      default: {}
    }
  }
}