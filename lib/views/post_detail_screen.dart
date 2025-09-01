import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/blog_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/blog_viewmodel.dart';
import '../utils/app_theme.dart';

class PostDetailScreen extends StatefulWidget {
  final BlogPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  late BlogPost _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Comments',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentPost.comments.length}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer2<BlogViewModel, AuthViewModel>(
        builder: (context, blogViewModel, authViewModel, child) {
          // Update current post from the blog view model
          final updatedPost = blogViewModel.posts.firstWhere(
            (post) => post.id == _currentPost.id,
            orElse: () => _currentPost,
          );
          _currentPost = updatedPost;

          return Column(
            children: [
              // Post preview section
              _buildPostPreview(blogViewModel, authViewModel),
              
              // Comments section
              Expanded(
                child: _buildCommentsSection(authViewModel, blogViewModel),
              ),
              
              // Add comment section or login prompt (fixed at bottom)
              SafeArea(
                child: authViewModel.isAuthenticated
                    ? _buildAddCommentSection(authViewModel, blogViewModel)
                    : _buildLoginPrompt(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostPreview(BlogViewModel blogViewModel, AuthViewModel authViewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textGray.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info and date
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryOrange,
                backgroundImage: _currentPost.authorPhotoUrl != null 
                    ? NetworkImage(_currentPost.authorPhotoUrl!) 
                    : null,
                child: _currentPost.authorPhotoUrl == null
                    ? Text(
                        _currentPost.authorName.isNotEmpty ? _currentPost.authorName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentPost.authorName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _formatDate(_currentPost.createdAt),
                      style: GoogleFonts.poppins(
                        color: AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Post title
          Text(
            _currentPost.title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Post content preview
          Text(
            _currentPost.content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textGray,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: _currentPost.likedBy.contains(authViewModel.user?.email) 
                    ? Icons.thumb_up 
                    : Icons.thumb_up_outlined,
                label: '${_currentPost.likes}',
                onTap: authViewModel.isAuthenticated 
                    ? () => blogViewModel.likePost(_currentPost.id!, authViewModel.user!.email)
                    : null,
                isActive: _currentPost.likedBy.contains(authViewModel.user?.email),
              ),
              _buildActionButton(
                icon: _currentPost.dislikedBy.contains(authViewModel.user?.email) 
                    ? Icons.thumb_down 
                    : Icons.thumb_down_outlined,
                label: '${_currentPost.dislikes}',
                onTap: authViewModel.isAuthenticated 
                    ? () => blogViewModel.dislikePost(_currentPost.id!, authViewModel.user!.email)
                    : null,
                isActive: _currentPost.dislikedBy.contains(authViewModel.user?.email),
              ),
              _buildActionButton(
                icon: Icons.comment,
                label: '${_currentPost.comments.length}',
                onTap: () {
                  // Scroll to comments section
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                isActive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryOrange.withValues(alpha: 0.1) : AppColors.lightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 20, 
              color: isActive ? AppColors.primaryOrange : AppColors.textGray,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isActive ? AppColors.primaryOrange : AppColors.textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(AuthViewModel authViewModel, BlogViewModel blogViewModel) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comments header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.comment, color: AppColors.primaryOrange, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Discussion',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentPost.comments.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Comments list
          Expanded(
            child: _currentPost.comments.isNotEmpty 
                ? ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    itemCount: _currentPost.comments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final comment = _currentPost.comments[index];
                      return _buildCommentItem(comment, authViewModel, blogViewModel);
                    },
                  )
                : _buildNoCommentsMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCommentSection(AuthViewModel authViewModel, BlogViewModel blogViewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.textGray.withValues(alpha: 0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textGray.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryOrange,
            backgroundImage: authViewModel.user?.photoURL != null 
                ? NetworkImage(authViewModel.user!.photoURL!) 
                : null,
            child: authViewModel.user?.photoURL == null
                ? Text(
                    (authViewModel.user?.displayName != null && authViewModel.user!.displayName.isNotEmpty)
                        ? authViewModel.user!.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 40,
                maxHeight: 120,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.textGray.withValues(alpha: 0.2)),
                ),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textGray, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                  maxLines: null,
                  maxLength: 500,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _addComment(authViewModel, blogViewModel),
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () => _addComment(authViewModel, blogViewModel),
              icon: const Icon(Icons.send, color: AppColors.white, size: 16),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.textGray.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.login, color: AppColors.primaryOrange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Join the conversation! Sign in to comment.',
              style: GoogleFonts.poppins(
                color: AppColors.textGray,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            height: 36,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCommentsMessage() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // Hide the message when keyboard is visible to save space
    if (keyboardHeight > 0) {
      return const SizedBox.shrink();
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start the conversation!',
              style: GoogleFonts.poppins(
                color: AppColors.darkGray,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your thoughts on this post.',
              style: GoogleFonts.poppins(
                color: AppColors.textGray,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, AuthViewModel authViewModel, BlogViewModel blogViewModel) {
    final isOwner = authViewModel.user?.email == comment.authorEmail;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryOrange,
                backgroundImage: comment.authorPhotoUrl != null 
                    ? NetworkImage(comment.authorPhotoUrl!) 
                    : null,
                child: comment.authorPhotoUrl == null
                    ? Text(
                        comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _formatDate(comment.createdAt),
                          style: GoogleFonts.poppins(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                        if (comment.edited) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Edited',
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editComment(comment, blogViewModel);
                    } else if (value == 'delete') {
                      _deleteComment(comment, blogViewModel);
                    }
                  },
                  icon: Icon(Icons.more_vert, color: AppColors.textGray, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: AppColors.primaryOrange),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: AppColors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.darkGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _addComment(AuthViewModel authViewModel, BlogViewModel blogViewModel) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = authViewModel.user!;
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      authorName: user.displayName,
      authorEmail: user.email,
      authorPhotoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );

    final success = await blogViewModel.addComment(_currentPost.id!, comment);
    if (success && mounted) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment added successfully!', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add comment. Please try again.', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _editComment(Comment comment, BlogViewModel blogViewModel) {
    final controller = TextEditingController(text: comment.content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Comment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Edit your comment...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () async {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty && newContent != comment.content) {
                final updatedComment = comment.copyWith(content: newContent);
                final success = await blogViewModel.updateComment(_currentPost.id!, updatedComment);
                
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comment updated successfully!', style: GoogleFonts.poppins()),
                      backgroundColor: AppColors.green,
                    ),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: Text('Update', style: GoogleFonts.poppins(color: AppColors.primaryOrange)),
          ),
        ],
      ),
    );
  }

  void _deleteComment(Comment comment, BlogViewModel blogViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Comment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete this comment? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await blogViewModel.deleteComment(_currentPost.id!, comment.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Comment deleted successfully!', style: GoogleFonts.poppins()),
                    backgroundColor: AppColors.green,
                  ),
                );
              }
            },
            child: Text('Delete', style: GoogleFonts.poppins(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
