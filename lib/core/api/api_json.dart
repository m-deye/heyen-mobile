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
  final details = asJsonMap(json['details']);
  final collected = <String>[];

  void addMessages(Object? value) {
    if (value is List) {
      for (final item in value) {
        final text = item.toString().trim();
        if (text.isNotEmpty) {
          collected.add(text);
        }
      }
    } else if (value is String && value.trim().isNotEmpty) {
      collected.add(value.trim());
    }
  }

  addMessages(details['formErrors']);
  final fieldErrors = details['fieldErrors'];
  if (fieldErrors is Map) {
    for (final entry in fieldErrors.entries) {
      final french = frenchApiFieldError(entry.key.toString());
      if (french != null) {
        collected.add(french);
      } else {
        addMessages(entry.value);
      }
    }
  }

  if (collected.isNotEmpty) {
    return collected.toSet().join('\n');
  }

  final message = json['message']?.toString().trim() ?? '';
  return message.isEmpty ? fallback : message;
}

String? frenchApiFieldError(String field) {
  return switch (field) {
    'firstName' => 'Le prénom doit contenir au moins 2 caractères.',
    'lastName' => 'Le nom doit contenir au moins 2 caractères.',
    'phone' => 'Indiquez un numéro mauritanien à 8 chiffres.',
    'password' => 'Le mot de passe doit contenir au moins 8 caractères.',
    'accountType' => 'Choisissez Particulier ou Commerçant.',
    _ => null,
  };
}
