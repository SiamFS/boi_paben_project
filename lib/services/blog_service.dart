import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blog_model.dart';

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'blogs';

  // Get all blog posts
  Future<List<BlogPost>> getAllPosts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BlogPost.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  // Create a new post
  Future<void> createPost(BlogPost post) async {
    try {
      final postData = post.toMap();
      await _firestore.collection(_collection).add(postData);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Update a post
  Future<void> updatePost(String postId, BlogPost updatedPost) async {
    try {
      final postData = updatedPost.toMap();
      postData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(_collection).doc(postId).update(postData);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Like a post (toggle)
  Future<void> likePost(String postId, String userEmail) async {
    try {
      final docRef = _firestore.collection(_collection).doc(postId);
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) throw Exception('Post not found');
        
        final data = doc.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        final dislikedBy = List<String>.from(data['dislikedBy'] ?? []);
        
        // Remove from disliked if present
        if (dislikedBy.contains(userEmail)) {
          dislikedBy.remove(userEmail);
          transaction.update(docRef, {
            'dislikedBy': dislikedBy,
            'dislikes': FieldValue.increment(-1),
          });
        }
        
        // Toggle like
        if (likedBy.contains(userEmail)) {
          // Remove like
          likedBy.remove(userEmail);
          transaction.update(docRef, {
            'likedBy': likedBy,
            'likes': FieldValue.increment(-1),
          });
        } else {
          // Add like
          likedBy.add(userEmail);
          transaction.update(docRef, {
            'likedBy': likedBy,
            'likes': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  // Dislike a post (toggle)
  Future<void> dislikePost(String postId, String userEmail) async {
    try {
      final docRef = _firestore.collection(_collection).doc(postId);
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) throw Exception('Post not found');
        
        final data = doc.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        final dislikedBy = List<String>.from(data['dislikedBy'] ?? []);
        
        // Remove from liked if present
        if (likedBy.contains(userEmail)) {
          likedBy.remove(userEmail);
          transaction.update(docRef, {
            'likedBy': likedBy,
            'likes': FieldValue.increment(-1),
          });
        }
        
        // Toggle dislike
        if (dislikedBy.contains(userEmail)) {
          // Remove dislike
          dislikedBy.remove(userEmail);
          transaction.update(docRef, {
            'dislikedBy': dislikedBy,
            'dislikes': FieldValue.increment(-1),
          });
        } else {
          // Add dislike
          dislikedBy.add(userEmail);
          transaction.update(docRef, {
            'dislikedBy': dislikedBy,
            'dislikes': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to dislike post: $e');
    }
  }

  // Add comment to a post
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Update a comment in a post
  Future<void> updateComment(String postId, Comment updatedComment) async {
    try {
      // Get the current post
      final doc = await _firestore.collection(_collection).doc(postId).get();
      if (!doc.exists) throw Exception('Post not found');

      final data = doc.data() as Map<String, dynamic>;
      final comments = (data['comments'] as List<dynamic>)
          .map((comment) => Comment.fromMap(comment))
          .toList();

      // Find and update the comment
      final commentIndex = comments.indexWhere((c) => c.id == updatedComment.id);
      if (commentIndex == -1) throw Exception('Comment not found');

      comments[commentIndex] = updatedComment.copyWith(edited: true);

      // Update the document
      await _firestore.collection(_collection).doc(postId).update({
        'comments': comments.map((c) => c.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  // Delete a comment from a post
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      // Get the current post
      final doc = await _firestore.collection(_collection).doc(postId).get();
      if (!doc.exists) throw Exception('Post not found');

      final data = doc.data() as Map<String, dynamic>;
      final comments = (data['comments'] as List<dynamic>)
          .map((comment) => Comment.fromMap(comment))
          .toList();

      // Remove the comment
      comments.removeWhere((c) => c.id == commentId);

      // Update the document
      await _firestore.collection(_collection).doc(postId).update({
        'comments': comments.map((c) => c.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Get posts by user email
  Future<List<BlogPost>> getPostsByUser(String email) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('authorEmail', isEqualTo: email)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BlogPost.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load user posts: $e');
    }
  }

  // Search posts by title or content
  Future<List<BlogPost>> searchPosts(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      
      final posts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BlogPost.fromMap(data, doc.id);
      }).toList();

      // Filter posts that contain the query in title or content
      return posts.where((post) =>
          post.title.toLowerCase().contains(query.toLowerCase()) ||
          post.content.toLowerCase().contains(query.toLowerCase())).toList();
    } catch (e) {
      throw Exception('Failed to search posts: $e');
    }
  }

  // Real-time posts stream
  Stream<List<BlogPost>> getPostsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BlogPost.fromMap(data, doc.id);
      }).toList();
    });
  }
}
