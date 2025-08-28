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
import '../widgets/book_details_modal.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'Latest'; // Latest, Price Low to High, Price High to Low, A-Z, Z-A
  String _searchQuery = '';
  
  final TextEditingController _searchController = TextEditingController();
  
  // Available categories - you can expand this based on your data
  final List<String> _categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Academic',
    'Children',
    'Biography',
    'History',
    'Science',
    'Technology',
    'Literature',
  ];
  
  final List<String> _sortOptions = [
    'Latest',
    'Price Low to High',
    'Price High to Low',
    'A-Z',
    'Z-A',
  ];

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> _filterAndSortBooks(List<Book> books) {
    List<Book> filteredBooks = books;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredBooks = filteredBooks.where((book) {
        return book.bookTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               book.authorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               book.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Filter by category
    if (_selectedCategory != 'All') {
      filteredBooks = filteredBooks.where((book) {
        return book.category.toLowerCase() == _selectedCategory.toLowerCase();
      }).toList();
    }
    
    // Sort books
    switch (_sortBy) {
      case 'Latest':
        // Assuming newer books have higher indices or you can add a timestamp field
        filteredBooks = filteredBooks.reversed.toList();
        break;
      case 'Price Low to High':
        filteredBooks.sort((a, b) => 
          (double.tryParse(a.price) ?? 0).compareTo(double.tryParse(b.price) ?? 0));
        break;
      case 'Price High to Low':
        filteredBooks.sort((a, b) => 
          (double.tryParse(b.price) ?? 0).compareTo(double.tryParse(a.price) ?? 0));
        break;
      case 'A-Z':
        filteredBooks.sort((a, b) => a.bookTitle.compareTo(b.bookTitle));
        break;
      case 'Z-A':
        filteredBooks.sort((a, b) => b.bookTitle.compareTo(a.bookTitle));
        break;
    }
    
    return filteredBooks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Consumer<CartViewModel>(
            builder: (context, cart, child) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.cart);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
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
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.lightGray,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search books, authors, categories...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Category and Sort Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            isDense: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value ?? 'All';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Sort Filter
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sort By',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: _sortBy,
                            isDense: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                            ),
                            items: _sortOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(
                                  option,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value ?? 'Latest';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Books Grid
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
                
                final filteredBooks = _filterAndSortBooks(bookViewModel.books);
                
                if (filteredBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty || _selectedCategory != 'All'
                              ? Icons.search_off
                              : Icons.book_outlined,
                          size: 64,
                          color: AppColors.textGray,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedCategory != 'All'
                              ? 'No books found'
                              : 'No books available',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textGray,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _selectedCategory != 'All'
                              ? 'Try different search criteria'
                              : 'Be the first to sell a book!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textGray,
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
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return _buildBookCard(book);
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

  Widget _buildBookCard(Book book) {
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
            flex: 3,
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
                                  userId: auth.user!.uid,
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
          Expanded(
            flex: 2,
            child: Padding(
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
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '৳${book.price}',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          book.category,
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryOrange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
