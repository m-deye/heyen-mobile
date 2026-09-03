class ApiNotConfiguredException implements Exception {
  const ApiNotConfiguredException();

  @override
  String toString() => 'API backend non configuree.';
}
