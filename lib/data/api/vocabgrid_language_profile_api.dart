import 'package:dio/dio.dart';

import 'api_client.dart';
import 'language_profile_api.dart';

/// Talks to the real VocabGrid backend for per-language learning profiles.
class VocabGridLanguageProfileApi implements LanguageProfileApi {
  VocabGridLanguageProfileApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<LanguageProfileData>> getMyLanguages() async {
    try {
      final response = await _client.dio.get('/api/User/languages');
      return (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map(LanguageProfileData.fromJson)
          .whereType<LanguageProfileData>()
          .toList();
    } catch (_) {
      // An unreadable list is indistinguishable from "no languages yet" to
      // every caller here, and both mean "nothing to show".
      return const [];
    }
  }

  @override
  Future<LanguageProfileResult> getLanguage(String languageCode) async {
    try {
      final response = await _client.dio.get('/api/User/languages/$languageCode');
      return _resultFrom(response.data);
    } on DioException catch (error) {
      // 404 means the learner has never selected this language. That is the
      // question this call exists to answer, not a failure.
      if (error.response?.statusCode == 404) return const LanguageProfileResult.notStarted();
      return const LanguageProfileResult.networkError();
    } catch (_) {
      return const LanguageProfileResult.networkError();
    }
  }

  @override
  Future<LanguageProfileResult> switchTo(String languageCode, {String? languageName}) async {
    try {
      final response = await _client.dio.put('/api/User/languages/switch', data: {
        'languageCode': languageCode,
        if (languageName != null && languageName.isNotEmpty) 'languageName': languageName,
      });
      return _resultFrom(response.data);
    } on DioException catch (error) {
      return _errorFrom(error);
    } catch (_) {
      return const LanguageProfileResult.networkError();
    }
  }

  @override
  Future<LanguageProfileResult> completeSetup(
    String languageCode, {
    required String proficiencyLevel,
    required List<int> categoryIds,
    String? difficultyMode,
  }) async {
    try {
      final response = await _client.dio.put('/api/User/languages/$languageCode/setup', data: {
        'proficiencyLevel': proficiencyLevel,
        'categoryIds': categoryIds,
        if (difficultyMode != null && difficultyMode.isNotEmpty) 'difficultyMode': difficultyMode,
      });
      return _resultFrom(response.data);
    } on DioException catch (error) {
      return _errorFrom(error);
    } catch (_) {
      return const LanguageProfileResult.networkError();
    }
  }

  LanguageProfileResult _resultFrom(dynamic data) {
    if (data is! Map<String, dynamic>) return const LanguageProfileResult.networkError();
    final profile = LanguageProfileData.fromJson(data);
    return profile == null
        ? const LanguageProfileResult.networkError()
        : LanguageProfileResult.success(profile);
  }

  /// A 400 carries a reason the learner can act on (an unknown category, the
  /// target language matching their native one); anything else is treated as
  /// a connectivity problem and retried later rather than shown as a rule
  /// they broke.
  LanguageProfileResult _errorFrom(DioException error) {
    if (error.response?.statusCode != 400) return const LanguageProfileResult.networkError();

    final body = error.response?.data;
    if (body is String && body.isNotEmpty) return LanguageProfileResult.validationError(body);
    if (body is Map<String, dynamic>) {
      final errors = body['errors'];
      if (errors is Map<String, dynamic>) {
        final messages = errors.values.whereType<List>().expand((e) => e).whereType<String>().join(' ');
        if (messages.isNotEmpty) return LanguageProfileResult.validationError(messages);
      }
      final title = body['title'];
      if (title is String && title.isNotEmpty) return LanguageProfileResult.validationError(title);
    }
    return const LanguageProfileResult.networkError();
  }
}

/// Swappable default, the same role `AuthStore.api` plays for `AuthApi` —
/// tests reassign this to [FakeLanguageProfileApi].
LanguageProfileApi languageProfileApi = VocabGridLanguageProfileApi();
