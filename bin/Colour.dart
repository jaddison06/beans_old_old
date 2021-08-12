/// RGBA colour with RGB values from **0-255** and alpha from **0-1**
///
/// Everything's mutable so you can use .. to make & chain changes.
class Colour {
  int r, g, b, a;
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
  static Colour grey(int brightness) {
    return Colour(brightness, brightness, brightness);
  }

  static Colour get red   => Colour(255, 0, 0);
  static Colour get green => Colour(0, 255, 0);
  static Colour get blue  => Colour(0, 0, 255);

  static Colour get cyan    => Colour(0, 255, 255);
  static Colour get magenta => Colour(255, 0, 255);
  static Colour get yellow  => Colour(255, 255, 0);

  static Colour get black => Colour(0, 0, 0);
  static Colour get white => Colour(255, 255, 255);
  static Colour get transparent => Colour(0, 0, 0, 0);
}