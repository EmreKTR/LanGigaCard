import 'api_client.dart';
import 'language_api.dart';

/// Fetches the supported languages from the real backend.
class VocabGridLanguageApi implements LanguageApi {
  VocabGridLanguageApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<LanguageData>> getLanguages() async {
    final response = await _client.dio.get('/api/Language');
    return (response.data as List)
        .map((e) => _fromJson(e as Map<String, dynamic>))
        .toList();
  }

  LanguageData _fromJson(Map<String, dynamic> json) => LanguageData(
        code: json['code'] as String,
        name: json['name'] as String,
        nativeName: json['nativeName'] as String? ?? json['name'] as String,
        flagCode: json['flagCode'] as String? ?? json['code'] as String,
        isActive: json['isActive'] as bool? ?? true,
      );
}

LanguageApi languageApi = VocabGridLanguageApi();
