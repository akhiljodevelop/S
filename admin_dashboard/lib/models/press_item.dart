class PressItem {
  final String? id;
  final String source;
  final String content;
  final String url;
  final int sortOrder;

  PressItem({
    this.id,
    required this.source,
    required this.content,
    required this.url,
    required this.sortOrder,
  });

  factory PressItem.fromJson(Map<String, dynamic> json) {
    return PressItem(
      id: json['id'],
      source: json['source'],
      content: json['content'],
      url: json['url'] ?? '#',
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'source': source,
      'content': content,
      'url': url,
      'sort_order': sortOrder,
    };
    if (id != null) data['id'] = id!;
    return data;
  }
}
