import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'books';

  Future<List<Book>> getBooks() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      
      final books = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['_id'] = doc.id; 
        return Book.fromJson(data);
      }).toList();
      
      print('BookService: Loaded ${books.length} books');
      final availableBooks = books.where((book) => book.availability != 'sold').length;
      print('BookService: $availableBooks available books');
      
      return books;
    } catch (e) {
      print('BookService error: $e');
      throw Exception('Failed to load books: $e');
    }
  }

  // Get books as a stream for real-time updates
  Stream<List<Book>> getBooksStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
          final books = snapshot.docs.map((doc) {
            final data = doc.data();
            data['_id'] = doc.id;
            return Book.fromJson(data);
          }).toList();
          
          print('BookService Stream: Loaded ${books.length} books');
          return books;
        });
  }

  // Get only available books (not sold)
  Future<List<Book>> getAvailableBooks() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .get();
      
      final books = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['_id'] = doc.id; 
        return Book.fromJson(data);
      }).where((book) => book.availability != 'sold').toList();
      
      print('BookService: Found ${books.length} available books');
      return books;
    } catch (e) {
      print('BookService getAvailableBooks error: $e');
      throw Exception('Failed to load available books: $e');
    }
  }

  Future<void> uploadBook(Book book) async {
    try {
      final bookData = book.toJson();
      bookData['createdAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(_collection).add(bookData);
    } catch (e) {
      throw Exception('Failed to upload book: $e');
    }
  }

  Future<List<Book>> getBooksByUser(String email) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['_id'] = doc.id;
        return Book.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load user books: $e');
    }
  }

  Future<List<Book>> getBooksByCategory(String category) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['_id'] = doc.id;
        return Book.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load books by category: $e');
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection(_collection).doc(bookId).delete();
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      if (book.id == null) {
        throw Exception('Book ID is required for updating');
      }
      
      final bookData = book.toJson();
      bookData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(_collection).doc(book.id).update(bookData);
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  Future<void> updateBookAvailability(String bookId, String availability) async {
    try {
      await _firestore.collection(_collection).doc(bookId).update({
        'availability': availability,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update book availability: $e');
    }
  }

  // Check if book is available
  Future<bool> isBookAvailable(String bookId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['availability'] != 'sold';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
