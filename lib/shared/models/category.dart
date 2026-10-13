class Category {
  const Category({
    required this.id,
    required this.label,
    required this.description,
    required this.imageLabel,
    this.apiId = '',
    this.imageUrl,
  });

  /// Route / filter key: cloud slug (`epicerie`) when present.
  final String id;

  /// Prisma CUID from the API, when the payload includes both id and slug.
  final String apiId;
  final String label;
  final String description;
  final String imageLabel;
  final String? imageUrl;

  bool matchesRef(String value) {
    final ref = value.trim().toLowerCase();
    if (ref.isEmpty) {
      return false;
    }
    if (id.trim().toLowerCase() == ref) {
      return true;
    }
    return apiId.isNotEmpty && apiId.trim().toLowerCase() == ref;
  }
}
