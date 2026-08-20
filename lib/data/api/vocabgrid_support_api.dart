import '../../data/api/api_client.dart';
import 'support_api.dart';

/// Talks to the real VocabGrid backend for problem reports.
class VocabGridSupportApi implements SupportApi {
  VocabGridSupportApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<bool> reportProblem(String message) async {
    try {
      await _client.dio.post('/api/Support/report', data: {'message': message});
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Swappable default, the same role `AuthStore.api` plays for `AuthApi` —
/// tests reassign this to [FakeSupportApi].
SupportApi supportApi = VocabGridSupportApi();
