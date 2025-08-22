import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'books';

  Future<List<Book>> getBooks() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['_id'] = doc.id; // Add document ID
        return Book.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching books: $e');
      throw Exception('Failed to load books: $e');
    }
  }

  Future<void> uploadBook(Book book) async {
    try {
      final bookData = book.toJson();
      bookData['createdAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(_collection).add(bookData);
      print("Book uploaded successfully!");
    } catch (e) {
      print('Error uploading book: $e');
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
      print('Error fetching user books: $e');
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
      print('Error fetching books by category: $e');
      throw Exception('Failed to load books by category: $e');
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection(_collection).doc(bookId).delete();
      print("Book deleted successfully!");
    } catch (e) {
      print('Error deleting book: $e');
      throw Exception('Failed to delete book: $e');
    }
  }

  Future<void> updateBookAvailability(String bookId, String availability) async {
    try {
      await _firestore.collection(_collection).doc(bookId).update({
        'availability': availability,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("Book availability updated successfully!");
    } catch (e) {
      print('Error updating book availability: $e');
      throw Exception('Failed to update book availability: $e');
    }
  }
}
