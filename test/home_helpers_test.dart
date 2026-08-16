import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/screens/home/home_screen.dart';

void main() {
  group('greetingFor', () {
    test('greets by time of day instead of always saying "Good morning"', () {
      // Asserts the slot rather than the wording: the copy is localized now,
      // and the boundary hours are what this function actually decides.
      expect(greetingFor(DateTime(2026, 8, 8, 0)), DayPart.morning);
      expect(greetingFor(DateTime(2026, 8, 8, 11, 59)), DayPart.morning);
      expect(greetingFor(DateTime(2026, 8, 8, 12)), DayPart.afternoon);
      expect(greetingFor(DateTime(2026, 8, 8, 17, 59)), DayPart.afternoon);
      expect(greetingFor(DateTime(2026, 8, 8, 18)), DayPart.evening);
      expect(greetingFor(DateTime(2026, 8, 8, 23, 59)), DayPart.evening);
    });
  });

  group('initialsFor', () {
    test('builds initials from first and last name', () {
      expect(initialsFor('Sarah Johnson'), 'SJ');
    });

    test('handles a single name', () {
      expect(initialsFor('Sarah'), 'S');
    });

    test('does not crash on empty or whitespace-only names', () {
      // The previous implementation called substring(0, 1) on '' and threw
      // a RangeError for a blank name.
      expect(initialsFor(''), '?');
      expect(initialsFor('   '), '?');
    });

    test('collapses repeated spaces rather than reading them as names', () {
      expect(initialsFor('Ada    Lovelace'), 'AL');
    });

    test('uppercases and supports non-ASCII names', () {
      expect(initialsFor('ada lovelace'), 'AL');
      expect(initialsFor('Élodie Ćurić'), 'ÉĆ');
    });

    test('uses the first and last of three or more names', () {
      expect(initialsFor('Jean Paul Sartre'), 'JS');
    });
  });
}
