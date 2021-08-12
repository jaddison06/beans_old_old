import 'Colour.dart';

class WindowTitleBarConfig {
  Colour col = Colours.grey(80)..a = 200;
  Colour iconCol = Colours.black;
  Colour iconHoverCol = Colours.white..a = 80;
  Colour iconClickCol = Colours.white;
  int height = 25;
  int iconSize = 15;
  int crossROffset = 80;
  int dtROffset = 40;
}

/// Holds all configuration data for Beans, whether it's set by the user, or programmaticaly.
class Config {
  static Config? _instance;

  Config._();

  static Config get instance {
    _instance ??= Config._();
    return _instance!;
  }

  final windowTitleBar = WindowTitleBarConfig();

}