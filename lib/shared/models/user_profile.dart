import 'client_type.dart';

class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.type,
    required this.phone,
    required this.whatsApp,
    required this.address,
    this.shopName = '',
  });

  final String fullName;
  final ClientType type;
  final String phone;
  final String whatsApp;
  final String address;
  final String shopName;

  bool get isCommercant => type.isCommercant;

  factory UserProfile.fromJson(Map<String, Object?> json) {
    final firstName = _readString(json, ['firstName', 'first_name']);
    final lastName = _readString(json, ['lastName', 'last_name']);
    final combined = '$firstName $lastName'.trim();

    return UserProfile(
      fullName: combined.isEmpty
          ? _readString(json, ['full_name', 'fullName', 'name'])
          : combined,
      type: ClientType.fromApi(
        _readString(json, ['role', 'type', 'client_type', 'clientType']),
      ),
      phone: _readString(json, ['phone']),
      whatsApp: _readString(json, ['whatsapp', 'whatsApp']),
      address: _readString(json, ['address']),
      shopName: _readString(json, [
        'shop_name',
        'shopName',
        'company_name',
        'companyName',
      ]),
    );
  }

  static String _readString(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        return value.toString();
      }
    }

    return '';
  }
}
