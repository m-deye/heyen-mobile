import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_json.dart';
import '../../../core/api/api_unreachable.dart';
import '../../../core/dev/dev_seed_data.dart';
import '../../../shared/models/client_type.dart';
import '../../../shared/models/user_profile.dart';
import '../../auth/application/auth_session_controller.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final config = ref.watch(apiConfigProvider);
  if (!config.isConfigured) {
    final type =
        ref.watch(authSessionControllerProvider)?.type ??
        ClientType.particulier;
    return DevProfileRepository(type);
  }

  return ApiProfileRepository(ref.watch(dioProvider));
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final session = ref.watch(authSessionControllerProvider);
  final profile = await ref.watch(profileRepositoryProvider).getProfile();
  if (session == null) {
    return profile;
  }
  if (profile == null) {
    return session.toProfile();
  }

  return UserProfile(
    fullName: profile.fullName.isNotEmpty ? profile.fullName : session.fullName,
    type: session.type,
    phone: profile.phone.isNotEmpty ? profile.phone : session.phone,
    whatsApp: profile.whatsApp.isNotEmpty ? profile.whatsApp : session.whatsApp,
    address: profile.address.isNotEmpty ? profile.address : session.address,
    shopName: session.shopName.isNotEmpty ? session.shopName : profile.shopName,
  );
});

abstract class ProfileRepository {
  Future<UserProfile?> getProfile();
}

class ApiProfileRepository implements ProfileRepository {
  const ApiProfileRepository(this._dio);

  final Dio _dio;

  @override
  Future<UserProfile?> getProfile() async {
    try {
      final response = await _dio.get<Object?>(ApiEndpoints.me);
      final data = asJsonMap(unwrapApiData(response.data));
      if (data.isEmpty) {
        return null;
      }

      return UserProfile.fromJson(data);
    } on DioException catch (error) {
      if (isApiUnreachable(error)) {
        return null;
      }
      rethrow;
    }
  }
}

class DevProfileRepository implements ProfileRepository {
  const DevProfileRepository(this.clientType);

  final ClientType clientType;

  @override
  Future<UserProfile?> getProfile() async => DevSeedData.profileFor(clientType);
}
