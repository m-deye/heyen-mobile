Map<String, Object?> asJsonMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return Map<String, Object?>.from(value);
  }
  return const {};
}

Object? unwrapApiData(Object? payload) {
  final json = asJsonMap(payload);
  if (json.containsKey('data')) {
    return json['data'];
  }
  return payload;
}

List<Map<String, Object?>> unwrapApiList(Object? payload) {
  final data = unwrapApiData(payload);
  final items = switch (data) {
    {'items': final List<dynamic> nested} => nested,
    {'results': final List<dynamic> results} => results,
    final List<dynamic> list => list,
    _ => const <dynamic>[],
  };

  return [
    for (final item in items)
      if (item is Map) Map<String, Object?>.from(item),
  ];
}

String readApiString(Map<String, Object?> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      return value.toString();
    }
  }
  return '';
}

String apiErrorMessage(
  Object? payload, {
  String fallback = 'Une erreur est survenue.',
}) {
  final json = asJsonMap(payload);
  final message = json['message']?.toString().trim() ?? '';
  return message.isEmpty ? fallback : message;
}
