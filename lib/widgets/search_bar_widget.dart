import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../utils/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final List<Book> books;
  final Function(List<Book>, bool, String) onSearchUpdate; // (filteredBooks, isSearching, query)

  const SearchBarWidget({
    super.key,
    required this.books,
    required this.onSearchUpdate,
  });

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSearchUpdate(widget.books, false, '');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    final filteredBooks = _filterBooks(widget.books, value);
    widget.onSearchUpdate(filteredBooks, _isSearching, value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    final filteredBooks = _filterBooks(widget.books, '');
    widget.onSearchUpdate(filteredBooks, _isSearching, '');
  }

  List<Book> _filterBooks(List<Book> books, String searchQuery) {
    if (searchQuery.isEmpty) return books;
    
    return books.where((book) {
      final query = searchQuery.toLowerCase();
      return book.bookTitle.toLowerCase().contains(query) ||
             book.authorName.toLowerCase().contains(query) ||
             book.category.toLowerCase().contains(query) ||
             book.bookDescription.toLowerCase().contains(query) ||
             (book.publisher?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          )
        : SizedBox.shrink(),
    );
  }
  
  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        widget.onSearchUpdate(widget.books, false, '');
      } else {
        final filteredBooks = _filterBooks(widget.books, _searchQuery);
        widget.onSearchUpdate(filteredBooks, true, _searchQuery);
      }
    });
  }

  // Getter for current search state
  bool get isSearching => _isSearching;
}
