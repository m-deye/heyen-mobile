class Category {
  const Category({
    required this.id,
    required this.label,
    required this.description,
    required this.imageLabel,
    this.imageUrl,
  });

  final String id;
  final String label;
  final String description;
  final String imageLabel;
  final String? imageUrl;
}
