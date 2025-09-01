import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String? id;
  final String title;
  final String content;
  final String authorName;
  final String authorEmail;
  final String? authorPhotoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  int likes;
  int dislikes;
  final List<String> likedBy;
  final List<String> dislikedBy;
  List<Comment> comments;
  final List<String> tags;
  final String? imageUrl;

  BlogPost({
    this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorEmail,
    this.authorPhotoUrl,
    required this.createdAt,
    this.updatedAt,
    this.likes = 0,
    this.dislikes = 0,
    List<String>? likedBy,
    List<String>? dislikedBy,
    List<Comment>? comments,
    this.tags = const [],
    this.imageUrl,
  }) : likedBy = likedBy ?? [],
       dislikedBy = dislikedBy ?? [],
       comments = comments ?? [];

  factory BlogPost.fromMap(Map<String, dynamic> map, String documentId) {
    return BlogPost(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorName: map['authorName'] ?? '',
      authorEmail: map['authorEmail'] ?? '',
      authorPhotoUrl: map['authorPhotoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      likes: map['likes'] ?? 0,
      dislikes: map['dislikes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      dislikedBy: List<String>.from(map['dislikedBy'] ?? []),
      comments: (map['comments'] as List<dynamic>?)
          ?.map((comment) => Comment.fromMap(comment))
          .toList() ?? [],
      tags: List<String>.from(map['tags'] ?? []),
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'authorPhotoUrl': authorPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likes': likes,
      'dislikes': dislikes,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'tags': tags,
      'imageUrl': imageUrl,
    };
  }

  BlogPost copyWith({
    String? id,
    String? title,
    String? content,
    String? authorName,
    String? authorEmail,
    String? authorPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    int? dislikes,
    List<String>? likedBy,
    List<String>? dislikedBy,
    List<Comment>? comments,
    List<String>? tags,
    String? imageUrl,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      likedBy: likedBy ?? this.likedBy,
      dislikedBy: dislikedBy ?? this.dislikedBy,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class Comment {
  final String id;
  final String content;
  final String authorName;
  final String authorEmail;
  final String? authorPhotoUrl;
  final DateTime createdAt;
  final bool edited;

  Comment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.authorEmail,
    this.authorPhotoUrl,
    required this.createdAt,
    this.edited = false,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      authorName: map['authorName'] ?? '',
      authorEmail: map['authorEmail'] ?? '',
      authorPhotoUrl: map['authorPhotoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      edited: map['edited'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'authorPhotoUrl': authorPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'edited': edited,
    };
  }

  Comment copyWith({
    String? id,
    String? content,
    String? authorName,
    String? authorEmail,
    String? authorPhotoUrl,
    DateTime? createdAt,
    bool? edited,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      edited: edited ?? this.edited,
    );
  }
}
