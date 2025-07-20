import 'package:cloud_firestore/cloud_firestore.dart';

class WardrobeItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final String description;
  final String? imageUrl;
  final List<String> tags;
  final String userId; // ✅ TAMBAH USER ID
  final DateTime createdAt;
  final DateTime? lastWorn;
  final bool favorite; // ✅ KEEP nama 'favorite' sesuai existing

  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.description,
    this.imageUrl,
    required this.tags,
    required this.userId, // ✅ TAMBAH USER ID
    required this.createdAt,
    this.lastWorn,
    this.favorite = false,
  });

  // ✅ FIRESTORE INTEGRATION
  factory WardrobeItem.fromFirestore(Map<String, dynamic> data, String docId) {
    return WardrobeItem(
      id: docId,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      color: data['color'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastWorn: (data['lastWorn'] as Timestamp?)?.toDate(),
      favorite: data['favorite'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'color': color,
      'description': description,
      'imageUrl': imageUrl,
      'tags': tags,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastWorn': lastWorn != null ? Timestamp.fromDate(lastWorn!) : null,
      'favorite': favorite,
    };
  }

  // ✅ EXISTING MAP METHODS (sesuai struktur existing)
  factory WardrobeItem.fromMap(Map<String, dynamic> map) {
    return WardrobeItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      color: map['color']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['image']?.toString(), // Map 'image' to 'imageUrl'
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      userId: map['userId']?.toString() ?? '', // ✅ TAMBAH USER ID
      createdAt: DateTime.now(), // ✅ DEFAULT VALUE
      lastWorn: map['lastWorn'] != null ? DateTime.tryParse(map['lastWorn'].toString()) : null,
      favorite: map['favorite'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'description': description,
      'image': imageUrl,  // Map back to 'image' field
      'tags': tags,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'lastWorn': lastWorn?.toIso8601String(),
      'favorite': favorite,
    };
  }

  // ✅ UTILITY METHODS
  WardrobeItem copyWith({
    String? id,
    String? name,
    String? category,
    String? color,
    String? description,
    String? imageUrl,
    List<String>? tags,
    String? userId,
    DateTime? createdAt,
    DateTime? lastWorn,
    bool? favorite,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      lastWorn: lastWorn ?? this.lastWorn,
      favorite: favorite ?? this.favorite,
    );
  }

  // ✅ HELPER METHODS
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty && imageUrl != 'null';
  
  bool get hasBeenWorn => lastWorn != null;
  
  int get daysSinceLastWorn {
    if (lastWorn == null) return -1;
    return DateTime.now().difference(lastWorn!).inDays;
  }
  
  String get formattedLastWorn {
    if (lastWorn == null) return 'Never worn';
    
    final days = daysSinceLastWorn;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).round()} weeks ago';
    return '${(days / 30).round()} months ago';
  }

  // ✅ SEARCH & FILTER HELPERS
  bool matchesSearch(String query) {
    final searchTerm = query.toLowerCase();
    return name.toLowerCase().contains(searchTerm) ||
           category.toLowerCase().contains(searchTerm) ||
           color.toLowerCase().contains(searchTerm) ||
           description.toLowerCase().contains(searchTerm) ||
           tags.any((tag) => tag.toLowerCase().contains(searchTerm));
  }

  bool hasAnyTag(List<String> searchTags) {
    if (searchTags.isEmpty) return true;
    return searchTags.any((searchTag) => 
        tags.any((itemTag) => itemTag.toLowerCase() == searchTag.toLowerCase()));
  }

  // ✅ COMPATIBILITY dengan existing code yang expect 'isFavorite'
  bool get isFavorite => favorite;

  // ✅ FOR DEBUGGING
  @override
  String toString() {
    return 'WardrobeItem(id: $id, name: $name, category: $category, color: $color, tags: $tags, imageUrl: $imageUrl, favorite: $favorite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WardrobeItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
