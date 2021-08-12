import 'dart_codegen.dart';

/// FontCache represents a whole font family, and provides the operator `[]` to get a specific font size from that family.
/// Use the static method [family] to get an instance, and call [destroyAll] at program end.
class FontCache {
  final _fonts = <int, BeansFont>{};
  final String _fontName;

  /// private constructor
  FontCache._(this._fontName);

  /// destroy all the fonts associated with this font family
  void _destroy() {
    for (var size in _fonts.keys) {
      _fonts[size]!.Destroy();
    }
    _fonts.clear();
  }

  int _pxToPt(int px) {
    return px ~/ 1.333;
  }

  int? _getPt(int? pt, int? px) {
    if (pt == null && px != null) {
      pt = _pxToPt(px);
    }
    return pt;
  }

  int? get _defaultPt => _getPt(defaultPt, defaultPx);

  /// Get the [BeansFont] with size [pt] or [px]. [pt] is used if both are provided. Similarly to [family],
  /// if both [pt] and [px] are null, then [_defaultPt] is used. If that's also null, a [StateError] is thrown.
  /// 
  /// Do **not** call [BeansFont.Destroy] on the returned [BeansFont].
  BeansFont font({int? pt, int? px}) {
    pt = _getPt(pt, px);
    if (pt == null) {
      pt = _defaultPt;
      if (pt == null) throw StateError('FontCache.font was called with a null size, a null defaultPt, and a null defaultPx.');
    }
    if (!_fonts.containsKey(pt)) {
      _fonts[pt] = BeansFont(_fontName, pt);
    }
    return _fonts[pt]!;
  }

  //* STATIC MEMBERS & METHODS

  static final _instances = <String, FontCache>{};

  static String? defaultFamily;
  static int? defaultPt;
  static int? defaultPx;

  /// get a [FontCache] for the font file at [fontName].
  /// 
  /// If [fontName] is null, then [defaultFamily] is used. If that's also null, a [StateError] is thrown.
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
    }
    _instances.clear();
  }
}