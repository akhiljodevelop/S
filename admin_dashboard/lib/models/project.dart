class Project {
  final String? id;
  final String category;
  final String title;
  final String? metadataInfo;
  final String? description;
  final List<String> images;
  final int sortOrder;

  Project({
    this.id,
    required this.category,
    required this.title,
    this.metadataInfo,
    this.description,
    required this.images,
    required this.sortOrder,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      category: json['category'],
      title: json['title'],
      metadataInfo: json['metadata_info'],
      description: json['description'],
      images: List<String>.from(json['images'] ?? []),
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'category': category,
      'title': title,
      'metadata_info': metadataInfo,
      'description': description,
      'images': images,
      'sort_order': sortOrder,
    };
    if (id != null) data['id'] = id!;
    return data;
  }
}
