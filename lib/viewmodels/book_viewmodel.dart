import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';
import 'dart:async';

class BookViewModel extends ChangeNotifier {
  final BookService _bookService = BookService();
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Book>>? _booksSubscription;

  List<Book> get books => _books;
  List<Book> get availableBooks => _books.where((book) => book.availability != 'sold').toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BookViewModel() {
    // Start listening to real-time updates
    _startBooksStream();
  }

  void _startBooksStream() {
    _booksSubscription = _bookService.getBooksStream().listen(
      (books) {
        _books = books;
        print('BookViewModel: Received ${books.length} books from stream');
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        print('BookViewModel stream error: $error');
        notifyListeners();
      },
    );
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _bookService.getBooks();
      print('Fetched ${_books.length} books, ${availableBooks.length} available');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _books = [];
      print('Error fetching books: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadBook(Book book) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _bookService.uploadBook(book);
      await fetchBooks();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBook(String? bookId) async {
    if (bookId == null) throw Exception('Book ID is null');
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _bookService.deleteBook(bookId);
      await fetchBooks(); 
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBook(Book book) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _bookService.updateBook(book);
      await fetchBooks(); 
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Force refresh books data
  Future<void> forceRefresh() async {
    print('BookViewModel: Force refreshing books data');
    await fetchBooks();
  }

  @override
  void dispose() {
    _booksSubscription?.cancel();
    super.dispose();
  }
}
