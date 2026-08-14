import 'package:flutter/material.dart';

/// Maps a category's `iconName` from the API (e.g. "sports_soccer") to the
/// Flutter icon this app renders for it. The API can't send an [IconData]
/// directly — icons are compile-time constants — so this table is the
/// bridge. Every name the API seeds today (verified live) is covered; an
/// unrecognized name (e.g. a category added server-side after this app
/// version shipped) falls back to a generic icon rather than crashing.
const _iconsByName = {
  'restaurant': Icons.restaurant_rounded,
  'flight': Icons.flight_rounded,
  'work': Icons.work_rounded,
  'laptop_mac': Icons.laptop_mac_rounded,
  'school': Icons.school_rounded,
  'local_movies': Icons.local_movies_rounded,
  'music_note': Icons.music_note_rounded,
  'sports_esports': Icons.sports_esports_rounded,
  'sports_soccer': Icons.sports_soccer_rounded,
  'favorite': Icons.favorite_rounded,
  'shopping_bag': Icons.shopping_bag_rounded,
  'family_restroom': Icons.family_restroom_rounded,
  'park': Icons.park_rounded,
  'science': Icons.science_rounded,
  'pets': Icons.pets_rounded,
};

IconData iconForCategory(String iconName) => _iconsByName[iconName] ?? Icons.label_outline_rounded;
