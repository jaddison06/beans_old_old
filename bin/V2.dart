import 'BeansWindowManager.dart';

/// Utility for working with 2D positions or sizes
///
/// Same as Colour in that everything's mutable so you can use .. to make & chain changes.
class V2 {
  int x, y;

  /// Default constructor
  V2(this.x, this.y);

  /// V2 at (0, 0)
  V2.origin() :
    x = 0,
    y = 0;
  
  /// V2 with [x] and [y] both at [val]
  V2.square(int val) :
    x = val,
    y = val;
  
  /// Take a main size/pos and a cross size/pos and convert them into real coordinates
  V2.fromMC(int main, int cross) :
    x = BeansWindowManager.isColumns ? cross : main,
    y = BeansWindowManager.isColumns ? main : cross;


  V2 operator + (Object other) {
    switch (other.runtimeType) {
      case int: return V2(
        x + (other as int),
        y + other
      );
      case V2: return V2(
        x + (other as V2).x,
        y + other.y
      );

      default: throw Exception('Cannot add an object of type ${other.runtimeType} to a V2.');
    }
  }

  @override
  String toString() => 'V2($x,$y)';

  /// Take this V2 as the top-right of a rectangle in 2D space, and [size] as the size of the rectangle.
  /// Is [hit] inside the rectangle?
  /// 
  /// [hitTest] is *inclusive* on the left/top and *exclusive* on the right/bottom.
  bool hitTest(V2 size, V2 hit) {
    return (
      hit.x >= x &&
      hit.y >= y &&
      hit.x < x + size.x &&
      hit.y < y + size.y
    );
  }
}