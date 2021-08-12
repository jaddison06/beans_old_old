import 'Colour.dart';

/// Holds all configuration data for Beans, whether it's set by the user, or programmaticaly.
class Config {
  static Config? _instance;

  Config._();

  static Config get instance {
    _instance ??= Config._();
    return _instance!;
  }

  Colour windowTitleBarCol = Colours.grey(80, 200);
  Colour windowTitleBarIconCol = Colours.black;
  int windowTitleBarHeight = 25;
  int windowTitleBarIconSize = 15;
}