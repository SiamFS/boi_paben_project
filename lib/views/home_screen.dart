import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/book_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookViewModel>(context, listen: false).fetchBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> _getFilteredBooks(List<Book> books) {
    if (_searchQuery.isEmpty) return books;
    
    return books.where((book) {
      final query = _searchQuery.toLowerCase();
      return book.bookTitle.toLowerCase().contains(query) ||
             book.authorName.toLowerCase().contains(query) ||
             book.category.toLowerCase().contains(query) ||
             book.bookDescription.toLowerCase().contains(query) ||
             (book.publisher?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, color: AppColors.white, size: 24),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'BoiPaben',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
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
                              title: Text('User Menu'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.logout),
                                    title: Text('Logout'),
                                    onTap: () {
                                      auth.signOut();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          Navigator.pushNamed(context, AppRoutes.login);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 18, color: AppColors.white),
                          const SizedBox(width: 4),
                          Text(
                            '0',
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search Bar (appears when searching)
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isSearching ? 60 : 0,
            color: AppColors.primaryOrange,
            child: _isSearching 
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search by book title, author, category...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primaryOrange,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                )
              : SizedBox.shrink(),
          ),
          // Hero Section (hide when searching)
          if (!_isSearching)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buy and Sell Your',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Books ',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'for the Best',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Price',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Easily buy and sell your books at unbeatable prices. Find new reads or earn from your old ones. Enjoy great value and a vast selection. Join our community and start trading today!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Scroll to books section
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Browse Books', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                            if (authViewModel.isAuthenticated) {
                              Navigator.pushNamed(context, AppRoutes.sellBook);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please log in to sell books.'),
                                  backgroundColor: AppColors.red,
                                ),
                              );
                              Navigator.pushNamed(context, AppRoutes.login);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryOrange,
                            side: BorderSide(color: AppColors.primaryOrange),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Sell Your Books', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Books Section
          Expanded(
            child: Consumer<BookViewModel>(
              builder: (context, bookViewModel, child) {
                if (bookViewModel.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading books...'),
                      ],
                    ),
                  );
                }
                
                if (bookViewModel.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading books',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please check your internet connection',
                          style: GoogleFonts.poppins(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            bookViewModel.clearError();
                            bookViewModel.fetchBooks();
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                final filteredBooks = _getFilteredBooks(bookViewModel.books);
                
                if (filteredBooks.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No books found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                
                if (bookViewModel.books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No books available',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Be the first to sell a book!',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await bookViewModel.fetchBooks();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return Card(
                        elevation: 4,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGray,
                                ),
                                child: Image.network(
                                  book.imageURL,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.bookTitle,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'by ${book.authorName}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textGray,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '৳${book.price}',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primaryOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
