import 'dart_codegen.dart';

/// FontCache represents a whole font family, and provides the operator `[]` to get a specific font size from that family.
/// Use the static method [family] to get an instance, and call [destroyAll] at program end.
class FontCache {
  final _fonts = <int, Font>{};
  final String _fontName;

  /// private constructor
  FontCache._(this._fontName);

  /// destroy all the fonts associated with this font family
  void _destroy() {
    for (var size in _fonts.keys) {
      _fonts[size]!.Destroy();
      _fonts.remove(size);
    }
  }

  /// Get the [Font] with size [size]
  /// Do **not** call [Font.Destroy].
  Font operator [](int size) {
    if (!_fonts.containsKey(size)) {
      _fonts[size] = Font(_fontName, size);
    }
    return _fonts[size]!;
  }

  //* STATIC MEMBERS & METHODS

  static final _instances = <String, FontCache>{};

  static String? defaultFamily;

  /// get a [FontCache] for the font file at [fontName].
  /// 
  /// If [fontName] is null, then [defaultFamily] is used. If that's also null, a StateError is thrown.
  static FontCache family([String? fontName]) {
    if (fontName == null) {
      if (defaultFamily == null) throw StateError('FontCache.family was called with a null fontName and a null defaultFamily.');
      fontName = defaultFamily;
    }
    if (!_instances.containsKey(fontName!)) {
      _instances[fontName] = FontCache._(fontName);
    }
    return _instances[fontName]!;
  }

  /// destroy all [FontCache]s and their associated fonts
  static void destroyAll() {
    for (var family in _instances.keys) {
      _instances[family]!._destroy();
      _instances.remove(family);
    }
  }
}