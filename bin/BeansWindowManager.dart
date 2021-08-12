import 'BeansWindow.dart';
import 'dart_codegen.dart';
import 'BeansRenderer.dart';
import 'dart:ffi';
import 'ColourWindow.dart';
import 'dart:math';
import 'XYPointer.dart';
import 'BeansRenderWindow.dart';
import 'CatchAll.dart';
import 'Colour.dart';
import 'Config.dart';
import 'V2.dart';

extension on Iterable<int> {
  int sum() {
    return isEmpty ? 0 : reduce((value, element) => value + element);
  }
}

V2 toV2(int main, int cross) {
  final isColumns = BeansWindowManager.layoutMode == BeansWindowLayoutMode.Columns;
  return V2(
    isColumns ? cross : main,
    isColumns ? main : cross
  );
}

/// WindowData represents metadata about a [BeansWindow], needed by the [BeansWindowManager].
class WindowData {
  V2 size;
  bool isFocused;
  bool isFloating;
  BeansWindow window;
  final _conf = Config.instance;

  bool _isHoveringCross = false;
  bool _isHoveringDT = false;
  bool _isClickingCross = false;

  /// Tests if the event at [hit] occured inside this window.
  /// [hitTest] is *inclusive* on the left/top and *exclusive* on the right/bottom.
  bool hitTest(V2 windowPos, V2 hit) {
    return windowPos.hitTest(size, hit);
  }

  /// Tests if the event at [hit] occured inside this window's title bar.
  bool isInTitleBar(V2 windowPos, V2 hit) {
    return _tbPos(windowPos).hitTest(_tbSize(windowPos), hit);
  }

  V2 _tbPos(V2 windowPos) => V2(windowPos.x, windowPos.y - _conf.windowTitleBar.height);
  V2 _tbSize(V2 windowPos) => V2(size.x, _conf.windowTitleBar.height);

  /// Render [window] using [x], [y], [width] and [height].
  void render(BeansRenderWindow rw, V2 windowPos, bool showDecorations) {
    window.render(rw, windowPos, size);
    if (showDecorations) {
      _renderWindowDecorations(rw, windowPos);
    }
  }

  void _renderWindowDecorations(BeansRenderWindow rw, V2 windowPos) {
    final tbPos = _tbPos(windowPos);
    final tbSize = _tbSize(windowPos);

    // bg col
    rw.FillRect(tbPos, tbSize, window.titleBarBGCol);
    // bar
    rw.FillRect(tbPos, tbSize, _conf.windowTitleBar.col);
    
    rw.SetColour(_conf.windowTitleBar.iconCol);

    // Draw boxes underneath icons
    if (_isHoveringCross) {
      _drawIconBox(rw, windowPos, _conf.windowTitleBar.crossROffset, false);
    } else if (_isHoveringDT) {
      _drawIconBox(rw, windowPos, _conf.windowTitleBar.dtROffset, false);
    } else if (_isClickingCross) {
      _drawIconBox(rw, windowPos, _conf.windowTitleBar.crossROffset, true);
    }

    _drawCrossHitbox(rw, windowPos);
    _drawDtHitbox(rw, windowPos);

    _drawCross(rw, windowPos);
    _drawDragTarget(rw, windowPos);
  }

  void _drawIconBox(BeansRenderWindow rw, V2 windowPos, int iconROffset, bool clicking) {
    rw.FillRect(_iconPos(windowPos, iconROffset), _iconSize(), clicking ? _conf.windowTitleBar.iconClickCol : _conf.windowTitleBar.iconHoverCol);
  }

  int _iconY(int windowY) {
    final tbY = windowY - _conf.windowTitleBar.height;
    final padding = (_conf.windowTitleBar.height - _conf.windowTitleBar.iconSize) ~/ 2;
    return tbY + padding;
  }

  V2 _iconSize() => V2.square(_conf.windowTitleBar.iconSize);

  V2 _iconPos(V2 windowPos, int rOffset) {
    final tbX2 = x2(windowPos.x);
    return V2(
      tbX2 - rOffset,
      _iconY(windowPos.y)
    );
  }

  void _drawCross(BeansRenderWindow rw, V2 windowPos) {
    final pos = _iconPos(windowPos, _conf.windowTitleBar.crossROffset);
    final pos2 = pos + _iconSize();
    rw.DrawLine(pos, pos2);
    rw.DrawLine(
      V2(pos2.x, pos.y),
      V2(pos.x, pos2.y)
    );
  }

  void _drawDragTarget(BeansRenderWindow rw, V2 windowPos) {
    final pos = _iconPos(windowPos, _conf.windowTitleBar.dtROffset);
    final size = _conf.windowTitleBar.iconSize;
    final thickness = 3;
    // not the distance between a's end and b's start, but between a's start and b's start.
    final gap = (size / 2) - (thickness / 2);
    for (var i=0; i<3; i++) {
      for (var j=0; j<3; j++) {
        final offset = V2(
          (i * gap).toInt(),
          (j * gap).toInt()
        );
        rw.FillRect(
          pos + offset,
          V2.square(thickness)
        );
      }
    }
  }

  void _drawIconHitbox(BeansRenderWindow rw, V2 windowPos, int rOffset) {
    rw.DrawRect(
      _iconPos(windowPos, rOffset),
      _iconSize(),
      Colours.black
    );
  }

  void _drawCrossHitbox(BeansRenderWindow rw, V2 windowPos) {
    _drawIconHitbox(rw, windowPos, _conf.windowTitleBar.crossROffset);
  }
  void _drawDtHitbox(BeansRenderWindow rw, V2 windowPos) {
    _drawIconHitbox(rw, windowPos, _conf.windowTitleBar.dtROffset);
  }

  bool _isInIcon(V2 windowPos, int iconROffset, V2 hit) {
    final ip = _iconPos(windowPos, iconROffset);
    final out = _iconPos(windowPos, iconROffset).hitTest(_iconSize(), hit);
    print('isInIcon with icon @ $ip, hit at $hit -> $out');
    return out;
  }

  /// check if a V2 is within the close button
  bool isInCross     (V2 windowPos, V2 hit) => _isInIcon(windowPos, _conf.windowTitleBar.crossROffset, hit);
  /// check if a V2 is within the drag target
  bool isInDragTarget(V2 windowPos, V2 hit) => _isInIcon(windowPos, _conf.windowTitleBar.dtROffset, hit);

  /// Render any hover boxes
  bool renderHovers(V2 windowPos, V2 mousePos) {
    _isHoveringCross = isInCross(windowPos, mousePos);
    _isHoveringDT = isInDragTarget(windowPos, mousePos);
    return _isHoveringCross || _isHoveringDT;
  }

  /// Render any click boxes.
  /// 
  /// This *DOES NOT* mean the click is confirmed - it could get cancelled. This just gets called when the mouse is down.
  bool renderMouseIsDown(V2 windowPos, V2 mousePos) {
    _isClickingCross = isInCross(windowPos, mousePos);
    return _isClickingCross;
    // don't bother checking the drag target - if the user puts their mouse down on it, special things will happen anyway
  }

  int x2(int x) => x + size.x;
  int y2(int y) => y + size.y;

  WindowData({
    required this.size,
    required this.isFocused,
    required this.isFloating,
    required this.window
  });
}

/// A row or column of windows
class Collection extends XYPointer with CatchAll {

  final _conf = Config.instance;

  final windows = <WindowData>[];

  bool get isColumns => BeansWindowManager.layoutMode == BeansWindowLayoutMode.Columns;

  void setCrossSize(int newCrossSize) {
    for (var wd in windows) {
      if (isColumns) {
        wd.size.x = newCrossSize;
      } else {
        wd.size.y = newCrossSize;
      }
    }
  }

  bool renderHovers(int crossPos, V2 event) {
    var out = false;
    _forEachWithMainPos((wd, mainPos) {
      out = wd.renderHovers(toV2(mainPos, crossPos), event);
      return out;
    });
    return out;
  }
  bool renderMouseIsDown(int crossPos, V2 event) {
    var out = false;
    _forEachWithMainPos((wd, mainPos) {
      out = wd.renderHovers(toV2(mainPos, crossPos), event);
      return out;
    });
    return out;
  }


  /// quits if [cb] returns `true`
  void _forEachWithMainPos(bool? Function(WindowData, int) cb) {
    var mainPos = isColumns ? _conf.windowTitleBar.height : 0;
    for (var wd in windows) {
      if (cb(wd, mainPos) == true) return;

      mainPos += isColumns ? wd.size.y : wd.size.x;
      if (isColumns) mainPos += _conf.windowTitleBar.height;
    }
  }

  void render(BeansRenderWindow rw, int crossPos) {
    _forEachWithMainPos((wd, mainPos) {
      final pos = toV2(mainPos, crossPos);
      catchAll(() {
        wd.render(
          rw,
          pos,
          true
        );
      }, (e, trace) {
        rw.FillRect(pos, wd.size, Colours.red);
        final msg = 'Error while rendering window ${wd.window.title}:\n$e\nTraceback:\n$trace';
        rw.DrawText(msg, pos, Colours.black);
      });
    });
  }

  WindowData? hitTest(V2 hit, int crossPos) {
    WindowData? out;
    _forEachWithMainPos((wd, mainPos) {
      if (
        wd.hitTest(
          toV2(mainPos, crossPos),
          hit
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

  final _conf = Config.instance;

  bool mouseIsDown = false;

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
    var crossPos = isColumns ? 0 : _conf.windowTitleBar.height;
    for (var collection in _windows) {
      if (cb(collection, crossPos) == true) return;

      crossPos += crossSize(collection.windows.last);
      if (!isColumns) crossPos += _conf.windowTitleBar.height;
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
        minSize: V2(69, 150),
        colour: Colours.white,
      ),
      ColourWindow(
        minSize: V2(500, 250),
        colour: Colour(66, 22, 120),
      ),
      ColourWindow(
        minSize: V2(100, 600),
        colour: Colours.yellow,
      ),
      ColourWindow(
        minSize: V2(1500, 50),
        colour: Colours.black,
      ),
      ColourWindow(
        minSize: V2(100, 900),
        colour: Colours.cyan,
      )
    ]);
  }

  void addNextTest() {
    if (_windowCount < _testWindows.length) {
      // print('adding new test window!');
      addWindow(_testWindows[_windowCount]);
    }
  }

  /// get minimum main axis size of the window
  int minMainSize (BeansWindow win) => isColumns ? win.minSize.y : win.minSize.x;
  /// get minimum cross axis size of the window
  int minCrossSize(BeansWindow win) => isColumns ? win.minSize.x : win.minSize.y;

  /// get minimum main axis size of the window, including the title bar
  int minMainSizeWithTitlebar(BeansWindow win) {
    var out = minMainSize(win);
    if (isColumns) out += _conf.windowTitleBar.height;
    return out;
  }

  /// get minimum cross axis size of the window, including the title bar
  int minCrossSizeWithTitlebar(BeansWindow win) {
    var out = minCrossSize(win);
    if (!isColumns) out += _conf.windowTitleBar.height;
    return out;
  }

  /// get current main axis size of the window
  int mainSize (WindowData wd) => isColumns ? wd.size.y : wd.size.x;
  /// get current cross axis size of the window
  int crossSize(WindowData wd) => isColumns ? wd.size.x : wd.size.y;


  /// for a column: if every window in the column was at `minHeight`, how tall would the whole thing be?
  int minPossibleMainSize(Collection collection) {
    return collection.windows.map((wd) => minMainSize(wd.window)).sum().toInt();
  }

  /// for a column: finds the window with the largest `minWidth`.
  int minPossibleCrossSize(Collection collection) {
    return minCrossSize(collection.windows.reduce((value, element) => minCrossSize(value.window) > minCrossSize(element.window) ? value : element).window);
  }

  /// minPossibleMainSize plus title bars
  int minPossibleMainSizeWithTitleBars(Collection collection) {
    var out = minPossibleMainSize(collection);
    if (isColumns) out += _conf.windowTitleBar.height;
    return out;
  }

  /// minPossibleCrossSize plus title bars
  int minPossibleCrossSizeWithTitleBars(Collection collection) {
    var out = minPossibleCrossSize(collection);
    if (!isColumns) out += _conf.windowTitleBar.height;
    return out;
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
      wd.size.y = newSize;
    } else {
      wd.size.x = newSize;
    }
  }

  /// set the cross axis size of a window
  void setCrossSize(WindowData wd, int newSize) {
    if (isColumns) {
      wd.size.x = newSize;
    } else {
      wd.size.y = newSize;
    }
  }

  /// Calculates x, y, width, height and initializes the [WindowData]. Assumes that resizing of other windows
  /// has already been done, and that it is **not** a floating window.
  void addWindowToCollection(BeansWindow win, Collection collection, {required int mainSize_, required int crossSize_, bool focus = true}) {
    collection.windows.add(
      WindowData(
        size: toV2(mainSize_, crossSize_),
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
      if (!isColumns) {
        sum += _conf.windowTitleBar.height;
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
    var gap = mainSize(collection.windows.last) - (minMainSize(collection.windows.last.window) + minMainSizeWithTitlebar(win));

    /// resize the current final window
    setMainSize(collection.windows.last, minMainSize(collection.windows.last.window) + (gap ~/ 2));
    resizeIfNeeded(collection, win);
    addWindowToCollection(
      win,
      collection,
      /*mainPos: offsetEnd(collection.last),
      crossPos: alignedStart(collection.last),*/
      mainSize_: minMainSize(win) + (gap ~/ 2), //? does this need to account for the titlebar?
      crossSize_: crossSize(collection.windows.last)
    );
  }

  /// Add a window to a collection using State 2 rules. Assumes that there is enough space, and that this won't cause the
  /// layout to overflow.
  void addState2(BeansWindow win, Collection collection) {
    final currentMainSize = totalMainAxisSize();
    //! must be a double
    final ratio = (currentMainSize - minMainSizeWithTitlebar(win)) / currentMainSize;
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
    
    final currentTotalMinCrossSize = _windows.map((collection) => minPossibleCrossSizeWithTitleBars(collection)).sum();

    // gap between all the current collections at their minPossibleCrossSize and this window at its minCrossSize
    final gap = totalCrossSize - (currentTotalMinCrossSize + minCrossSizeWithTitlebar(win));
    var crossSize_ = minCrossSize(win) + (gap ~/ 2); //? does this need to account for the title bar?

    final previousCollection = _windows.isEmpty ? null : _windows.last;

    _windows.add(Collection());

    var winMainSize = totalMainSize;
    if (isColumns) winMainSize -= _conf.windowTitleBar.height;

    resizeCollections(_windows.last, crossSize_);
    addWindowToCollection(
      win,
      _windows.last,
      /*mainPos: 0,
      crossPos: previousCollection == null ? 0 : alignedEnd(previousCollection.last),*/
      mainSize_: winMainSize,
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
      win.minSize.x > xPtr.value ||
      win.minSize.y > (yPtr.value - _conf.windowTitleBar.height)
    ) {
      error('Window ${win.title} had out-of-bounds minimum size: (${win.minSize.x}x${win.minSize.y}) in a (${xPtr.value}x${yPtr.value}) window, with titlebars of height ${_conf.windowTitleBar.height}.');
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
            minMainSizeWithTitlebar(win)
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
      // print('state 1!!');
      addState1(win, selection);
      return;
    }

    //* CHECK FOR STATE 2 CANDIDATES
    for (var candidate in _windows) {
      if (
        // It will be able to fit into the collection if all windows are resized
        (
          totalMainAxisSize() >= (
            minPossibleMainSizeWithTitleBars(candidate) +
            minMainSizeWithTitlebar(win)
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
      // print('state 2!!');
      addState2(win, selection);
      return;
    }

    //* CHECK IF STATE 3 IS APPLICABLE
    if (
      // a new collection with a cross size of the window's minCrossSize will fit into the layout
      totalCrossAxisSize() >= (
        _windows.map((collection) => minPossibleCrossSizeWithTitleBars(collection)).sum() +
        minCrossSizeWithTitlebar(win)
      )
    ) {
      // print('state 3!!');
      addState3(win);
      return;
    }
    
    // print('state 4!!');
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

  void _drawPanicScreen(BeansRenderWindow rw) {
    rw.DrawImage(_forgor, V2.square(0));
    rw.DrawText(panicMsg!, V2(0, _forgor.height), Colours.red);
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
      // that badly wrong we can stop handling our own error and just pass it up, which will lead to
      // Beans._panic() and a clean-ish program exit.
      if (_ren.handleErrors) {
        catchAll(() => _drawPanicScreen(rw),
        (e, trace) {
          //print('error while drawing panic screen!!');
          _ren.handleErrors = false;
        });
      } else {
        _drawPanicScreen(rw);
      }
      return;
    }
    _forEachCollectionWithCrossPos((collection, crossPos) {
      collection.render(rw, crossPos);
    });
    catchAll(() {
      // debug drawing here!
      rw.DrawText('deez nuts', V2.square(69), Colours.black);
    }, gpanic);
  }

  /// update the focused window based on [_x] and [_y]
  void _setFocusedWindow() {
    _forEachCollectionWithCrossPos((collection, crossPos) {
      final wd = collection.hitTest(v2FromPointers(), crossPos);
      if (wd != null) {
        wd.isFocused = true;
        return true;
      }
    });
  }

  /// possibly update title bar hover/click boxes on a mouse move event
  /// 
  /// returns whether an update was performed
  bool _updateTitleBarOnMouseMove(V2 eventPos) {
    var didUpdateTitleBar = false;
    _forEachCollectionWithCrossPos((collection, crossPos) {
      if (mouseIsDown) {
        didUpdateTitleBar = collection.renderMouseIsDown(crossPos, eventPos);
      } else {
        didUpdateTitleBar = collection.renderHovers(crossPos, eventPos);
      }
      return didUpdateTitleBar;
    });
    return didUpdateTitleBar;
  }

  bool _updateTitleBarOnMouseUp(V2 eventPos) {
    return false;
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
        final eventPos = v2FromPointers();

        if (_updateTitleBarOnMouseMove(eventPos)) return;

        _focusedWindow?.window.onMouseMove(eventPos);
        break;
      }

      case SDLEventType.MouseDown: {
        mouseIsDown = true;

        final button = event.GetMousePressReleaseData(xPtr, yPtr);
        _setFocusedWindow();

        if (button == MouseButton.Right) {
          _ren.quit();
        } else {
          addNextTest();
        }
        
        _focusedWindow?.window.onMouseDown(v2FromPointers(), button);
        break;
      }

      case SDLEventType.MouseUp: {
        mouseIsDown = false;

        final button = event.GetMousePressReleaseData(xPtr, yPtr);
        final eventPos = v2FromPointers();

        if (_updateTitleBarOnMouseUp(eventPos)) return;

        _focusedWindow?.window.onMouseUp(eventPos, button);
        break;
      }

      default: {}
    }
  }
}