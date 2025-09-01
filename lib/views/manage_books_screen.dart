import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/book_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/app_drawer.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<BookViewModel>(context, listen: false).fetchBooks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Books',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
      ),
      drawer: const AppDrawer(),
      body: Consumer2<BookViewModel, AuthViewModel>(
        builder: (context, bookViewModel, authViewModel, child) {
          if (bookViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!authViewModel.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please log in to manage your books',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Login', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            );
          }

          final userBooks = bookViewModel.books
              .where((book) => book.email == authViewModel.user?.email)
              .toList();

          if (userBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t posted any books yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 220,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          Navigator.pushNamed(context, AppRoutes.sellBook);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error navigating to sell book: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Sell Your First Book',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await bookViewModel.fetchBooks();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userBooks.length,
              itemBuilder: (context, index) {
                final book = userBooks[index];
                return _buildBookCard(book, bookViewModel);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookCard(Book book, BookViewModel bookViewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFFF3E0), // Light orange background
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book.imageURL,
                width: 90,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 120,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.book,
                      color: Colors.grey.shade400,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.bookTitle,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${book.authorName}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.category,
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TK${book.price}',
                    style: GoogleFonts.poppins(
                      color: AppColors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Action Icons Column
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editBook,
                      arguments: book,
                    );
                  },
                  icon: const Icon(Icons.edit),
                  color: AppColors.primaryOrange,
                  iconSize: 24,
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () {
                    _showDeleteDialog(book, bookViewModel);
                  },
                  icon: const Icon(Icons.delete),
                  color: AppColors.red,
                  iconSize: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Book book, BookViewModel bookViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book', style: GoogleFonts.poppins()),
        content: Text(
          'Are you sure you want to delete "${book.bookTitle}"? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              // Capture the ScaffoldMessenger before the async gap
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context); // Close the dialog
              
              try {
                await bookViewModel.deleteBook(book.id);
                if (!mounted) return; // Check if the widget is still mounted
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Book deleted successfully'),
                    backgroundColor: AppColors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return; // Check again in case of error
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete book: $e'),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
