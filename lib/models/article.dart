class Article {
  final String title;
  final String description;
  final String source;
  final String publishedAt;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.source,
    required this.publishedAt,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description',
      source: json['source']['name'] ?? 'Unknown source',
      publishedAt: json['publishedAt'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'publishedAt': publishedAt,
      'source': {'name': source},
    };
  }
}
