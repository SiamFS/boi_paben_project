import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../models/cart_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/book_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/app_drawer.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/book_details_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<SearchBarWidgetState> _searchBarKey = GlobalKey<SearchBarWidgetState>();
  List<Book> _filteredBooks = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookViewModel>(context, listen: false).fetchBooks();
      
      // Load cart items if user is authenticated
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      if (auth.isAuthenticated && auth.user != null) {
        Provider.of<CartViewModel>(context, listen: false).loadCartItems(auth.user!.uid);
      }
    });
  }

  void _onSearchUpdate(List<Book> filteredBooks, bool isSearching, String query) {
    setState(() {
      _filteredBooks = filteredBooks;
      _isSearching = isSearching;
      _searchQuery = query;
    });
  }

  void _toggleSearch() {
    _searchBarKey.currentState?.toggleSearch();
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
            onPressed: _toggleSearch,
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
                    Consumer<CartViewModel>(
                      builder: (context, cart, child) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to cart page
                            Navigator.pushNamed(context, AppRoutes.cart);
                          },
                          child: Container(
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
                                  '${cart.cartCount}',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
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
      body: Column(
        children: [
          // Search Bar Widget
          Consumer<BookViewModel>(
            builder: (context, bookViewModel, child) {
              return SearchBarWidget(
                key: _searchBarKey,
                books: bookViewModel.books,
                onSearchUpdate: _onSearchUpdate,
              );
            },
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
                            Navigator.pushNamed(context, AppRoutes.shop);
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
                
                final filteredBooks = _filteredBooks.isNotEmpty || _isSearching ? _filteredBooks : bookViewModel.books;
                
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
                  child: Column(
                    children: [
                      // Latest Books Header
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_stories,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Latest Books',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Books Grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            BookDetailsModal.show(context, book);
                                          },
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
                                        // Cart button overlay
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Consumer<CartViewModel>(
                                      builder: (context, cart, child) {
                                        return Consumer<AuthViewModel>(
                                          builder: (context, auth, child) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.1),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                onPressed: () async {
                                                  if (!auth.isAuthenticated) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Please log in to add items to cart'),
                                                        backgroundColor: AppColors.red,
                                                      ),
                                                    );
                                                    Navigator.pushNamed(context, AppRoutes.login);
                                                    return;
                                                  }
                                                  
                                                  // Check if book is already in cart
                                                  final isAlreadyInCart = cart.cartItems.any((item) => item.bookId == book.id);
                                                  
                                                  if (isAlreadyInCart) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Book "${book.bookTitle}" is already in your cart'),
                                                        backgroundColor: AppColors.primaryOrange,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  // Create CartItem and add to cart
                                                  final cartItem = CartItem(
                                                    id: '', // Will be set by Firestore
                                                    bookId: book.id ?? '',
                                                    bookTitle: book.bookTitle,
                                                    authorName: book.authorName,
                                                    category: book.category,
                                                    price: double.tryParse(book.price) ?? 0.0,
                                                    imageUrl: book.imageURL,
                                                    description: book.bookDescription,
                                                    userId: auth.user?.uid ?? '',
                                                    addedAt: DateTime.now(),
                                                    quantity: 1,
                                                  );
                                                  
                                                  final success = await cart.addToCart(cartItem);
                                                  
                                                  if (success) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Added "${book.bookTitle}" to cart'),
                                                        backgroundColor: AppColors.green,
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Failed to add item to cart'),
                                                        backgroundColor: AppColors.red,
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.add_shopping_cart,
                                                  color: AppColors.primaryOrange,
                                                  size: 20,
                                                ),
                                                constraints: BoxConstraints.tightFor(
                                                  width: 36,
                                                  height: 36,
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
                        ),
                      ],
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
