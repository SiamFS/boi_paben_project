import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';

class BookViewModel extends ChangeNotifier {
  final BookService _bookService = BookService();
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Remove automatic fetching from constructor
  BookViewModel();

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _bookService.getBooks();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _books = []; // Clear books on error
      print('Error in BookViewModel.fetchBooks: $e');
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
      await fetchBooks(); // Refresh the book list after uploading
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error in BookViewModel.uploadBook: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
