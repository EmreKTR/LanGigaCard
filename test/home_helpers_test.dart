import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/screens/home/home_screen.dart';

void main() {
  group('greetingFor', () {
    test('greets by time of day instead of always saying "Good morning"', () {
      expect(greetingFor(DateTime(2026, 8, 8, 0)), 'Good morning,');
      expect(greetingFor(DateTime(2026, 8, 8, 11, 59)), 'Good morning,');
      expect(greetingFor(DateTime(2026, 8, 8, 12)), 'Good afternoon,');
      expect(greetingFor(DateTime(2026, 8, 8, 17, 59)), 'Good afternoon,');
      expect(greetingFor(DateTime(2026, 8, 8, 18)), 'Good evening,');
      expect(greetingFor(DateTime(2026, 8, 8, 23, 59)), 'Good evening,');
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
