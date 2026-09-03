import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'api_json.dart';

enum ApiLinkStatus { localTest, checking, connected, unreachable }

final sessionFromApiProvider = NotifierProvider<SessionFromApi, bool>(
  SessionFromApi.new,
);

class SessionFromApi extends Notifier<bool> {
  @override
  bool build() => false;

  void markRemote() => state = true;

  void markLocal() => state = false;
}

final apiHealthProvider = FutureProvider<ApiLinkStatus>((ref) async {
  final config = ref.watch(apiConfigProvider);
  if (!config.isConfigured) {
    return ApiLinkStatus.localTest;
  }

  try {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl.trim(),
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        responseType: ResponseType.json,
      ),
    );
    final response = await dio.get<Object?>(ApiEndpoints.health);
    final data = asJsonMap(unwrapApiData(response.data));
    final status = data['status']?.toString().toLowerCase() ?? '';
    final database = data['database']?.toString().toLowerCase() ?? '';
    if (status == 'ok' || database == 'connected') {
      return ApiLinkStatus.connected;
    }
    return ApiLinkStatus.unreachable;
  } catch (_) {
    return ApiLinkStatus.unreachable;
  }
});
