/// Dynamic text-size preference, editable from Profile > App Preferences.
enum TextSizeOption { small, medium, large, extraLarge, automatic }

extension TextSizeOptionX on TextSizeOption {
  String get label => switch (this) {
        TextSizeOption.small => 'Small',
        TextSizeOption.medium => 'Medium',
        TextSizeOption.large => 'Large',
        TextSizeOption.extraLarge => 'Extra Large',
        TextSizeOption.automatic => 'Automatic',
      };

  /// Multiplier applied to [MediaQuery.textScaler] at the app root.
  double get scaleFactor => switch (this) {
        TextSizeOption.small => 0.9,
        TextSizeOption.medium => 1.0,
        TextSizeOption.large => 1.15,
        TextSizeOption.extraLarge => 1.3,
        TextSizeOption.automatic => 1.0,
      };
}

enum DifficultyMode { easy, adaptive, hard }

extension DifficultyModeX on DifficultyMode {
  String get label => switch (this) {
        DifficultyMode.easy => 'Easy',
        DifficultyMode.adaptive => 'Adaptive',
        DifficultyMode.hard => 'Hard',
      };
}
