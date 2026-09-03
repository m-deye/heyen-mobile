import 'package:dio/dio.dart';

import '../../../core/api/api_config.dart';
import '../../../core/api/api_json.dart';
import '../../../core/api/api_unreachable.dart';

class AddressesApi {
  const AddressesApi(this._dio);

  final Dio _dio;

  Future<String?> create({
    required String label,
    required String city,
    String? district,
    String? street,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        ApiEndpoints.addresses,
        data: {
          'label': label,
          'city': city,
          if (district != null && district.isNotEmpty) 'district': district,
          if (street != null && street.isNotEmpty) 'street': street,
          'isDefault': true,
        },
      );
      final data = asJsonMap(unwrapApiData(response.data));
      final id = data['id']?.toString() ?? '';
      return id.isEmpty ? null : id;
    } on DioException catch (error) {
      if (isApiUnreachable(error)) {
        return null;
      }
      rethrow;
    }
  }
}
