import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import '../services/blog_service.dart';

class BlogViewModel extends ChangeNotifier {
  final BlogService _blogService = BlogService();
  
  List<BlogPost> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BlogPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BlogViewModel() {
    fetchPosts();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch all posts
  Future<void> fetchPosts() async {
    _setLoading(true);
    _setError(null);

    try {
      _posts = await _blogService.getAllPosts();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      _posts = [];
    } finally {
      _setLoading(false);
    }
  }

  // Create a new post
  Future<bool> createPost(BlogPost post) async {
    _setLoading(true);
    _setError(null);

    try {
      await _blogService.createPost(post);
      await fetchPosts(); // Refresh the list
      _setError(null);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update a post
  Future<bool> updatePost(String postId, BlogPost updatedPost) async {
    _setLoading(true);
    _setError(null);

    try {
      await _blogService.updatePost(postId, updatedPost);
      await fetchPosts(); // Refresh the list
      _setError(null);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a post
  Future<bool> deletePost(String postId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _blogService.deletePost(postId);
      await fetchPosts(); // Refresh the list
      _setError(null);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Like a post
  Future<void> likePost(String postId, String userEmail) async {
    try {
      // Optimistically update the UI
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final wasDisliked = post.dislikedBy.contains(userEmail);

        // If it was disliked, remove the dislike
        if (wasDisliked) {
          post.dislikedBy.remove(userEmail);
          post.dislikes--;
        }

        // Toggle the like
        if (post.likedBy.contains(userEmail)) {
          post.likedBy.remove(userEmail);
          post.likes--;
        } else {
          post.likedBy.add(userEmail);
          post.likes++;
        }
        notifyListeners();
      }

      await _blogService.likePost(postId, userEmail);
      // Optionally, you can fetch from the server again to ensure data consistency,
      // but the optimistic update handles the UI. For now, we trust the backend call.
      // await fetchPosts(); 
    } catch (e) {
      _setError(e.toString());
      // If the call fails, you might want to revert the change.
      // For simplicity, we'll just log the error for now.
      // Consider implementing a revert mechanism for production apps.
      await fetchPosts(); // Re-fetch to get the correct state from the server on error
    }
  }

  // Dislike a post
  Future<void> dislikePost(String postId, String userEmail) async {
    try {
      // Optimistically update the UI
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final wasLiked = post.likedBy.contains(userEmail);

        // If it was liked, remove the like
        if (wasLiked) {
          post.likedBy.remove(userEmail);
          post.likes--;
        }

        // Toggle the dislike
        if (post.dislikedBy.contains(userEmail)) {
          post.dislikedBy.remove(userEmail);
          post.dislikes--;
        } else {
          post.dislikedBy.add(userEmail);
          post.dislikes++;
        }
        notifyListeners();
      }

      await _blogService.dislikePost(postId, userEmail);
      // As with like, we trust the backend call and don't force a refresh
      // await fetchPosts();
    } catch (e) {
      _setError(e.toString());
      // Revert on error
      await fetchPosts();
    }
  }

  // Add comment to a post
  Future<bool> addComment(String postId, Comment comment) async {
    try {
      // Optimistically update the UI first
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].comments.add(comment);
        notifyListeners();
      }

      await _blogService.addComment(postId, comment);
      return true;
    } catch (e) {
      _setError(e.toString());
      // Revert the optimistic update on error
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].comments.removeWhere((c) => c.id == comment.id);
        notifyListeners();
      }
      return false;
    }
  }

  // Update a comment
  Future<bool> updateComment(String postId, Comment updatedComment) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    Comment? originalComment;
    
    try {
      // Optimistically update the UI first
      if (postIndex != -1) {
        final commentIndex = _posts[postIndex].comments.indexWhere((c) => c.id == updatedComment.id);
        if (commentIndex != -1) {
          originalComment = _posts[postIndex].comments[commentIndex];
          _posts[postIndex].comments[commentIndex] = updatedComment.copyWith(edited: true);
          notifyListeners();
        }
      }

      await _blogService.updateComment(postId, updatedComment);
      return true;
    } catch (e) {
      _setError(e.toString());
      // Revert the optimistic update on error
      if (postIndex != -1 && originalComment != null) {
        final commentIndex = _posts[postIndex].comments.indexWhere((c) => c.id == updatedComment.id);
        if (commentIndex != -1) {
          _posts[postIndex].comments[commentIndex] = originalComment;
          notifyListeners();
        }
      }
      return false;
    }
  }

  // Delete a comment
  Future<bool> deleteComment(String postId, String commentId) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    Comment? removedComment;
    
    try {
      // Optimistically update the UI first
      if (postIndex != -1) {
        final commentIndex = _posts[postIndex].comments.indexWhere((c) => c.id == commentId);
        if (commentIndex != -1) {
          removedComment = _posts[postIndex].comments.removeAt(commentIndex);
          notifyListeners();
        }
      }

      await _blogService.deleteComment(postId, commentId);
      return true;
    } catch (e) {
      _setError(e.toString());
      // Revert the optimistic update on error
      if (postIndex != -1 && removedComment != null) {
        _posts[postIndex].comments.add(removedComment);
        notifyListeners();
      }
      return false;
    }
  }

  // Search posts
  Future<void> searchPosts(String query) async {
    if (query.isEmpty) {
      fetchPosts();
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      _posts = await _blogService.searchPosts(query);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      _posts = [];
    } finally {
      _setLoading(false);
    }
  }

  // Get posts by user
  Future<void> fetchPostsByUser(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      _posts = await _blogService.getPostsByUser(email);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      _posts = [];
    } finally {
      _setLoading(false);
    }
  }
}
