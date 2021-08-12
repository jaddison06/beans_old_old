/// RGBA colour with RGB values from **0-255** and alpha from **0-1**
class Colour {
  int r, g, b;
  int a;
  Colour(this.r, this.g, this.b, [this.a = 255]);

  Colour.fromCMYK(int c, int m, int y, int k, [int a = 255]):
    r = ((255 - c) * ((255 - k) / 255)).toInt(),
    g = ((255 - m) * ((255 - k) / 255)).toInt(),
    b = ((255 - y) * ((255 - k) / 255)).toInt(),
    a = a;
  
  @override
  String toString() => '$r, $g, $b, $a';
}

/// Utility list of colours
class Colours {
  static Colour grey(int brightness, [int a = 255]) {
    return Colour(brightness, brightness, brightness, a);
  }

  static Colour red   = Colour(255, 0, 0);
  static Colour green = Colour(0, 255, 0);
  static Colour blue  = Colour(0, 0, 255);

  static Colour cyan    = Colour(0, 255, 255);
  static Colour magenta = Colour(255, 0, 255);
  static Colour yellow  = Colour(255, 255, 0);

  static Colour black = Colour(0, 0, 0);
  static Colour white = Colour(255, 255, 255);
  static Colour transparent = Colour(0, 0, 0, 0);
}