class FashionArticle {
  final String id;
  final String title;
  final String excerpt;
  final String imageUrl;
  final String author;
  final DateTime publishDate;
  final int readTimeMinutes;
  final List<String> tags;
  final bool isBookmarked;
  final String category;

  FashionArticle({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    required this.author,
    required this.publishDate,
    required this.readTimeMinutes,
    required this.tags,
    this.isBookmarked = false,
    required this.category,
  });

  FashionArticle copyWith({bool? isBookmarked}) {
    return FashionArticle(
      id: id,
      title: title,
      excerpt: excerpt,
      imageUrl: imageUrl,
      author: author,
      publishDate: publishDate,
      readTimeMinutes: readTimeMinutes,
      tags: tags,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      category: category,
    );
  }
}
