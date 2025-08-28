import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/blog_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/blog_viewmodel.dart';
import '../utils/app_theme.dart';
import '../widgets/app_drawer.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import 'home_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  String _sortBy = 'date'; // 'date', 'likes', 'dislikes'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BlogViewModel>(context, listen: false).fetchPosts();
    });
  }

  List<BlogPost> _sortPosts(List<BlogPost> posts) {
    List<BlogPost> sortedPosts = List.from(posts);
    
    switch (_sortBy) {
      case 'likes':
        sortedPosts.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case 'dislikes':
        sortedPosts.sort((a, b) => b.dislikes.compareTo(a.dislikes));
        break;
      case 'date':
      default:
        sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    return sortedPosts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article_rounded, color: AppColors.white, size: 24),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'BoiPaben - Blog',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, auth, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        auth.isAuthenticated ? Icons.account_circle : Icons.login,
                        color: AppColors.white,
                      ),
                      onPressed: () {
                        if (auth.isAuthenticated) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('User Menu', style: GoogleFonts.poppins()),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.person),
                                    title: Text('Profile', style: GoogleFonts.poppins()),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.logout),
                                    title: Text('Logout', style: GoogleFonts.poppins()),
                                    onTap: () {
                                      Navigator.pop(context);
                                      auth.signOut();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          Navigator.pushNamed(context, '/login');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer2<BlogViewModel, AuthViewModel>(
        builder: (context, blogViewModel, authViewModel, child) {
          if (blogViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }

          if (blogViewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.textGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${blogViewModel.errorMessage}',
                    style: GoogleFonts.poppins(
                      color: AppColors.textGray,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => blogViewModel.fetchPosts(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Retry', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            );
          }

          if (blogViewModel.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: AppColors.textGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: GoogleFonts.poppins(
                      color: AppColors.textGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to share your thoughts!',
                    style: GoogleFonts.poppins(
                      color: AppColors.textGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryOrange,
            onRefresh: () => blogViewModel.fetchPosts(),
            child: Column(
              children: [
                // Sort dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sort by:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGray,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _sortBy,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _sortBy = newValue;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'date', child: Text('Latest')),
                          DropdownMenuItem(value: 'likes', child: Text('Most Liked')),
                          DropdownMenuItem(value: 'dislikes', child: Text('Most Disliked')),
                        ],
                      ),
                    ],
                  ),
                ),
                // Posts list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sortPosts(blogViewModel.posts).length,
                    itemBuilder: (context, index) {
                      final sortedPosts = _sortPosts(blogViewModel.posts);
                      final post = sortedPosts[index];
                      return _buildPostCard(context, post, blogViewModel, authViewModel);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          if (!authViewModel.isAuthenticated) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _navigateToCreatePost(context),
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: AppColors.white,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, BlogPost post, BlogViewModel blogViewModel, AuthViewModel authViewModel) {
    return GestureDetector(
      onTap: () => _navigateToPostDetail(context, post),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author info and date
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryOrange,
                    backgroundImage: post.authorPhotoUrl != null 
                        ? NetworkImage(post.authorPhotoUrl!) 
                        : null,
                    child: post.authorPhotoUrl == null
                        ? Text(
                            post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : 'U',
                            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatDate(post.createdAt),
                          style: GoogleFonts.poppins(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (authViewModel.user?.email == post.authorEmail)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEditPost(context, post);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, post, blogViewModel);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
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
              
              // Post title
              Text(
                post.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 8),
              
              // Post content (preview)
              Text(
                post.content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Post image if available
              if (post.imageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: AppColors.lightGray,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: AppColors.textGray),
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Tags
              if (post.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: post.tags.map((tag) => Chip(
                    label: Text(
                      '#$tag',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppColors.primaryOrange),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Action buttons
              _buildActionButtons(context, post, blogViewModel, authViewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BlogPost post, BlogViewModel blogViewModel, AuthViewModel authViewModel) {
    return Row(
      children: [
        _buildActionButton(
          icon: post.likedBy.contains(authViewModel.user?.email) 
              ? Icons.thumb_up 
              : Icons.thumb_up_outlined,
          label: '${post.likes}',
          onTap: authViewModel.isAuthenticated 
              ? () => blogViewModel.likePost(post.id!, authViewModel.user!.email)
              : null,
          isActive: post.likedBy.contains(authViewModel.user?.email),
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: post.dislikedBy.contains(authViewModel.user?.email) 
              ? Icons.thumb_down 
              : Icons.thumb_down_outlined,
          label: '${post.dislikes}',
          onTap: authViewModel.isAuthenticated 
              ? () => blogViewModel.dislikePost(post.id!, authViewModel.user!.email)
              : null,
          isActive: post.dislikedBy.contains(authViewModel.user?.email),
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.comment_outlined,
          label: '${post.comments.length}',
          onTap: () => _navigateToPostDetail(context, post),
        ),
        const Spacer(),
      ],
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 18, 
              color: isActive ? AppColors.primaryOrange : AppColors.textGray,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isActive ? AppColors.primaryOrange : AppColors.textGray,
              ),
            ),
          ],
        ),
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

  void _navigateToCreatePost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );
  }

  void _navigateToEditPost(BuildContext context, BlogPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePostScreen(post: post)),
    );
  }

  void _navigateToPostDetail(BuildContext context, BlogPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
    );
  }

  void _showDeleteDialog(BuildContext context, BlogPost post, BlogViewModel blogViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textGray),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await blogViewModel.deletePost(post.id!);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Post deleted successfully', style: GoogleFonts.poppins()),
                    backgroundColor: AppColors.green,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
