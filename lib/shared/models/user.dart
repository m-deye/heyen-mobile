import 'client_type.dart';
import 'user_profile.dart';

/// Identite client envoyee plus tard par Django (type compris).
class User {
  const User({
    required this.id,
    required this.fullName,
    required this.type,
    required this.phone,
    this.whatsApp = '',
    this.address = '',
    this.shopName = '',
  });

  final String id;
  final String fullName;
  final ClientType type;
  final String phone;
  final String whatsApp;
  final String address;
  final String shopName;

  bool get isCommercant => type.isCommercant;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'H';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  User copyWith({
    String? id,
    String? fullName,
    ClientType? type,
    String? phone,
    String? whatsApp,
    String? address,
    String? shopName,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      whatsApp: whatsApp ?? this.whatsApp,
      address: address ?? this.address,
      shopName: shopName ?? this.shopName,
    );
  }

  UserProfile toProfile() {
    return UserProfile(
      fullName: fullName,
      type: type,
      phone: phone,
      whatsApp: whatsApp,
      address: address,
      shopName: shopName,
    );
  }

  factory User.fromJson(Map<String, Object?> json) {
    final firstName = _readString(json, ['firstName', 'first_name']);
    final lastName = _readString(json, ['lastName', 'last_name']);
    final combinedName = '$firstName $lastName'.trim();
    final role = _readString(json, [
      'role',
      'type',
      'client_type',
      'clientType',
    ]);

    return User(
      id: _readString(json, ['id']),
      fullName: combinedName.isEmpty
          ? _readString(json, ['full_name', 'fullName', 'name'])
          : combinedName,
      type: ClientType.fromApi(role),
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
