import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/book_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/app_drawer.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/book_card_widget.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final GlobalKey<SearchBarWidgetState> _searchBarKey = GlobalKey<SearchBarWidgetState>();
  List<Book> _filteredBooks = [];
  bool _isSearching = false;
  String _selectedCategory = 'All';
  String _sortBy = 'Latest';
  
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

  void _onSearchUpdate(List<Book> filteredBooks, bool isSearching, String query) {
    setState(() {
      _filteredBooks = filteredBooks;
      _isSearching = isSearching;
    });
  }

  void _toggleSearch() {
    _searchBarKey.currentState?.toggleSearch();
  }

  List<Book> _getFilteredAndSortedBooks(List<Book> books) {
    List<Book> filteredBooks = books;
    
    // Filter by category
    if (_selectedCategory != 'All') {
      filteredBooks = filteredBooks.where((book) => 
        book.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }
    
    // Sort books
    switch (_sortBy) {
      case 'Price Low to High':
        filteredBooks.sort((a, b) => (double.tryParse(a.price) ?? 0).compareTo(double.tryParse(b.price) ?? 0));
        break;
      case 'Price High to Low':
        filteredBooks.sort((a, b) => (double.tryParse(b.price) ?? 0).compareTo(double.tryParse(a.price) ?? 0));
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront, color: AppColors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Shop',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
                          // Show profile options
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.person),
                                    title: Text('Profile'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // Navigate to profile
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.logout),
                                    title: Text('Logout'),
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
                          Navigator.pushNamed(context, AppRoutes.login);
                        }
                      },
                    ),
                    Consumer<CartViewModel>(
                      builder: (context, cart, child) {
                        return Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.shopping_cart_outlined, color: AppColors.white),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.cart);
                              },
                            ),
                            if (cart.cartCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${cart.cartCount}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
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
      body: Consumer<BookViewModel>(
        builder: (context, bookViewModel, child) {
          if (bookViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            );
          }

          if (bookViewModel.errorMessage?.isNotEmpty == true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading books',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bookViewModel.errorMessage!,
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => bookViewModel.fetchBooks(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Retry', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            );
          }

          final books = bookViewModel.availableBooks;
          
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: AppColors.textGray),
                  const SizedBox(height: 16),
                  Text(
                    'No books available',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              SearchBarWidget(
                key: _searchBarKey,
                books: books,
                onSearchUpdate: _onSearchUpdate,
              ),
              // Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  border: Border(
                    bottom: BorderSide(color: AppColors.textGray.withValues(alpha: 0.3)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildCategoryFilter()),
                    const SizedBox(width: 16),
                    _buildSortDropdown(),
                  ],
                ),
              ),
              Expanded(
                child: _buildBookGrid(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryOrange),
          style: GoogleFonts.poppins(color: AppColors.darkGray, fontSize: 14),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
          items: _categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          icon: Icon(Icons.sort, color: AppColors.primaryOrange),
          style: GoogleFonts.poppins(color: AppColors.darkGray, fontSize: 14),
          onChanged: (String? newValue) {
            setState(() {
              _sortBy = newValue!;
            });
          },
          items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.poppins(fontSize: 12)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBookGrid() {
    final booksToShow = _isSearching ? _filteredBooks : _getFilteredAndSortedBooks(
      Provider.of<BookViewModel>(context, listen: false).availableBooks
    );

    if (booksToShow.isEmpty && _isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textGray),
            const SizedBox(height: 16),
            Text(
              'No books found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: booksToShow.length,
        itemBuilder: (context, index) {
          final book = booksToShow[index];
          return BookCardWidget(
            book: book,
            showCartButton: true,
          );
        },
      ),
    );
  }
}
