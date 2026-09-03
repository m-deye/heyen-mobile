class DeliveryLocation {
  const DeliveryLocation({
    required this.neighborhood,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    this.phone = '',
  });

  final String neighborhood;
  final String landmark;
  final double latitude;
  final double longitude;
  final String phone;

  bool get isComplete =>
      neighborhood.trim().isNotEmpty && landmark.trim().isNotEmpty;

  bool get hasPhone => phone.trim().isNotEmpty;

  String get formattedAddress {
    final pin =
        '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    final address = '$neighborhood — près de $landmark ($pin)';
    if (!hasPhone) {
      return address;
    }
    return '$address · $phone';
  }

  DeliveryLocation copyWith({
    String? neighborhood,
    String? landmark,
    double? latitude,
    double? longitude,
    String? phone,
  }) {
    return DeliveryLocation(
      neighborhood: neighborhood ?? this.neighborhood,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
    );
  }

  factory DeliveryLocation.fromJson(Map<String, Object?> json) {
    return DeliveryLocation(
      neighborhood: json['neighborhood']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'neighborhood': neighborhood,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
    };
  }
}
