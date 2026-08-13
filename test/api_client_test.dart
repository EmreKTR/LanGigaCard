import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/api_client.dart';

void main() {
  group('resolveApiBaseUrl', () {
    test('Android emulator uses the 10.0.2.2 host alias', () {
      expect(
        resolveApiBaseUrl(isWeb: false, isAndroid: true),
        'http://10.0.2.2:5068',
      );
    });

    test('web uses localhost', () {
      expect(
        resolveApiBaseUrl(isWeb: true, isAndroid: false),
        'http://localhost:5068',
      );
    });

    test('desktop (neither web nor Android) uses localhost', () {
      expect(
        resolveApiBaseUrl(isWeb: false, isAndroid: false),
        'http://localhost:5068',
      );
    });
  });

  group('isAuthEndpointPath', () {
    test('the three auth endpoints are recognised', () {
      expect(isAuthEndpointPath('/api/Auth/register'), isTrue);
      expect(isAuthEndpointPath('/api/Auth/login'), isTrue);
      expect(isAuthEndpointPath('/api/Auth/refresh'), isTrue);
    });

    test('other endpoints are not', () {
      expect(isAuthEndpointPath('/api/Categories'), isFalse);
      expect(isAuthEndpointPath('/api/User/profile'), isFalse);
    });
  });
}
