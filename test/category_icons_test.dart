import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/theme/category_icons.dart';

void main() {
  test('known icon names map to the matching Material icon', () {
    expect(iconForCategory('restaurant'), Icons.restaurant_rounded);
    expect(iconForCategory('sports_soccer'), Icons.sports_soccer_rounded);
    expect(iconForCategory('pets'), Icons.pets_rounded);
  });

  test('an unrecognized icon name falls back to a generic icon instead of throwing', () {
    expect(iconForCategory('some_future_category_icon'), Icons.label_outline_rounded);
  });
}
