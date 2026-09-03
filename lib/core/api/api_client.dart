import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'api_json.dart';
import 'auth_token_store.dart';

final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  return const AuthTokenStore();
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(apiConfigProvider);
  if (!config.isConfigured) {
    throw const ApiNotConfiguredException();
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl.trim(),
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 8),
      responseType: ResponseType.json,
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  final tokens = ref.watch(authTokenStoreProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await tokens.readAccessToken();
        if (access != null && access.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final path = error.requestOptions.path;
        final alreadyRetried =
            error.requestOptions.extra['heynRetried'] == true;
        if (status != 401 || alreadyRetried || path.contains('/api/auth/')) {
          handler.next(error);
          return;
        }

        final refreshToken = await tokens.readRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          handler.next(error);
          return;
        }

        try {
          final refreshResponse = await dio.post<Object?>(
            ApiEndpoints.refresh,
            data: {'refreshToken': refreshToken},
            options: Options(extra: {'heynRetried': true}),
          );
          final data = asJsonMap(unwrapApiData(refreshResponse.data));
          final accessToken = data['accessToken']?.toString() ?? '';
          final nextRefresh = data['refreshToken']?.toString() ?? refreshToken;
          if (accessToken.isEmpty) {
            handler.next(error);
            return;
          }
          await tokens.save(
            accessToken: accessToken,
            refreshToken: nextRefresh,
          );

          final request = error.requestOptions;
          request.headers['Authorization'] = 'Bearer $accessToken';
          request.extra['heynRetried'] = true;
          final replay = await dio.fetch<Object?>(request);
          handler.resolve(replay);
        } catch (_) {
          handler.next(error);
        }
      },
    ),
  );

  return dio;
});
