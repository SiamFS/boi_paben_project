import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/blog_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/blog_viewmodel.dart';
import '../services/image_upload_service.dart';
import '../utils/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  final BlogPost? post; // If editing an existing post

  const CreatePostScreen({super.key, this.post});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final ImageUploadService _imageUploadService = ImageUploadService();
  
  File? _imageFile;
  bool _isLoading = false;
  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _imageUrlController.text = widget.post!.imageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Post' : 'Create New Post',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'An Awesome Blog Post Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        floatingLabelStyle: const TextStyle(color: AppColors.primaryOrange),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.trim().length < 5) {
                          return 'Title must be at least 5 characters long';
                        }
                        return null;
                      },
                      maxLength: 100,
                    ),
                    const SizedBox(height: 24),

                    // Content
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        hintText: 'Share your thoughts, experiences, or book recommendations...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        floatingLabelStyle: const TextStyle(color: AppColors.primaryOrange),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
                        ),
                      ),
                      maxLines: 10,
                      minLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter some content';
                        }
                        if (value.trim().length < 10) {
                          return 'Content must be at least 10 characters long';
                        }
                        return null;
                      },
                      maxLength: 2000,
                    ),
                    const SizedBox(height: 24),

                    // Image Upload
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Post Image',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildImagePicker(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: AppColors.textGray.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGray,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitPost,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _isEditing ? 'Update Post' : 'Create Post',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_imageFile != null) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryOrange, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _imageFile!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else if (_imageUrlController.text.isNotEmpty) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryOrange, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                _imageUrlController.text,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 48,
                  color: AppColors.textGray,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(
              (_imageFile != null || _imageUrlController.text.isNotEmpty) ? Icons.edit : Icons.camera_alt,
              color: AppColors.white,
            ),
            label: Text(
              (_imageFile != null || _imageUrlController.text.isNotEmpty) ? 'Change Photo' : 'Upload Photo',
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imageUploadService.showImageSourceDialog(context);
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageUrlController.clear(); // Clear URL if file is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final blogViewModel = Provider.of<BlogViewModel>(context, listen: false);

    if (!authViewModel.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must be logged in to create a post', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = authViewModel.user!;
      String? imageUrl;

      // Upload image if a file is selected
      if (_imageFile != null) {
        final pickedFile = XFile(_imageFile!.path);
        imageUrl = await _imageUploadService.uploadImage(pickedFile);
      } else if (_imageUrlController.text.trim().isNotEmpty) {
        imageUrl = _imageUrlController.text.trim();
      }

      final post = BlogPost(
        id: _isEditing ? widget.post!.id : null,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorName: user.displayName,
        authorEmail: user.email,
        authorPhotoUrl: user.photoURL,
        createdAt: _isEditing ? widget.post!.createdAt : DateTime.now(),
        updatedAt: _isEditing ? DateTime.now() : null,
        likes: _isEditing ? widget.post!.likes : 0,
        dislikes: _isEditing ? widget.post!.dislikes : 0,
        comments: _isEditing ? widget.post!.comments : [],
        tags: [], // Remove tags for simplicity
        imageUrl: imageUrl,
      );

      bool success;
      if (_isEditing) {
        success = await blogViewModel.updatePost(widget.post!.id!, post);
      } else {
        success = await blogViewModel.createPost(post);
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Post updated successfully!' : 'Post created successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isEditing ? 'update' : 'create'} post. Please try again.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
