import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../models/cart_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Process COD Payment
  Future<String?> processCODPayment({
    required String buyerId,
    required String buyerEmail,
    required String buyerName,
    required String buyerPhone,
    required String deliveryAddress,
    required String city,
    required String district,
    required String zipCode,
    required List<CartItem> cartItems,
    required double subtotal,
    required double deliveryFee,
    required double total,
    String? notes,
  }) async {
    try {
      // Create payment record with proper seller info
      List<PaymentItem> paymentItems = [];
      
      for (final item in cartItems) {
        // Get book details to fetch seller info
        final bookDoc = await _firestore.collection('books').doc(item.bookId).get();
        String sellerId = '';
        String sellerEmail = '';
        
        if (bookDoc.exists) {
          final bookData = bookDoc.data()!;
          sellerEmail = bookData['email'] ?? '';
          sellerId = bookData['seller'] ?? '';
        }
        
        paymentItems.add(PaymentItem(
          bookId: item.bookId,
          bookTitle: item.bookTitle,
          authorName: item.authorName,
          imageUrl: item.imageUrl,
          price: item.price,
          quantity: item.quantity,
          sellerId: sellerId,
          sellerEmail: sellerEmail,
        ));
      }

      final payment = Payment(
        id: '', // Will be set by Firestore
        orderId: _generateOrderId(),
        buyerId: buyerId,
        buyerEmail: buyerEmail,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        deliveryAddress: deliveryAddress,
        city: city,
        district: district,
        zipCode: zipCode,
        items: paymentItems,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        paymentMethod: 'COD',
        status: 'processing',
        createdAt: DateTime.now(),
        notes: notes,
      );

      // Start batch operation
      final batch = _firestore.batch();

      // Add payment record
      final paymentRef = _firestore.collection('payments').doc();
      final paymentData = payment.toJson();
      paymentData['id'] = paymentRef.id;
      batch.set(paymentRef, paymentData);

      // Update book availability to sold for each item
      for (final item in cartItems) {
        final bookRef = _firestore.collection('books').doc(item.bookId);
        batch.update(bookRef, {
          'availability': 'sold',
          'soldAt': FieldValue.serverTimestamp(),
          'soldTo': buyerEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Updating book ${item.bookId} availability to sold');
      }

      // Clear buyer's cart
      final cartQuery = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: buyerId)
          .get();
      
      for (final doc in cartQuery.docs) {
        batch.delete(doc.reference);
      }

      // Remove sold books from all other users' carts
      for (final item in cartItems) {
        final allCartQuery = await _firestore
            .collection('cart')
            .where('bookId', isEqualTo: item.bookId)
            .get();
        
        for (final doc in allCartQuery.docs) {
          batch.delete(doc.reference);
        }
      }

      // Commit batch
      await batch.commit();
      
      print('COD Payment processed successfully: ${paymentRef.id}');
      print('Books marked as sold: ${cartItems.map((item) => item.bookId).join(', ')}');

      return paymentRef.id;
    } catch (e) {
      print('Error processing COD payment: $e');
      return null;
    }
  }

  // Get payments for buyer (purchase history)
  Stream<List<Payment>> getBuyerPayments(String buyerId) {
    return _firestore
        .collection('payments')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) {
          final payments = snapshot.docs
              .map((doc) => Payment.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
          // Sort in memory to avoid Firestore index issues
          payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return payments;
        });
  }

  // Get sales data for seller (dashboard)
  Future<SalesData> getSellerSalesData(String sellerEmail) async {
    try {
      // Get all payments where seller has sold books
      final paymentsQuery = await _firestore
          .collection('payments')
          .get();

      List<SoldBook> soldBooks = [];

      for (final paymentDoc in paymentsQuery.docs) {
        final payment = Payment.fromJson({...paymentDoc.data(), 'id': paymentDoc.id});
        
        // Check if any items in this payment belong to this seller
        for (final item in payment.items) {
          // Get book details to check seller
          final bookDoc = await _firestore
              .collection('books')
              .doc(item.bookId)
              .get();
          
          if (bookDoc.exists) {
            final bookData = bookDoc.data()!;
            if (bookData['email'] == sellerEmail) {
              soldBooks.add(SoldBook(
                bookId: item.bookId,
                bookTitle: item.bookTitle,
                authorName: item.authorName,
                imageUrl: item.imageUrl,
                salePrice: item.price,
                buyerEmail: payment.buyerEmail,
                soldAt: payment.createdAt,
                status: payment.status,
                paymentId: payment.id,
              ));
            }
          }
        }
      }

      return SalesData.fromSoldBooks('', sellerEmail, soldBooks);
    } catch (e) {
      print('Error getting seller sales data: $e');
      return SalesData(
        sellerId: '',
        sellerEmail: sellerEmail,
        soldBooks: [],
        totalEarnings: 0,
        totalBooksSold: 0,
      );
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'delivered') 'deliveredAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  // Check if books in cart are still available
  Future<Map<String, bool>> checkBooksAvailability(List<String> bookIds) async {
    Map<String, bool> availability = {};
    
    try {
      for (final bookId in bookIds) {
        final bookDoc = await _firestore.collection('books').doc(bookId).get();
        if (bookDoc.exists) {
          final data = bookDoc.data()!;
          availability[bookId] = data['availability'] != 'sold';
        } else {
          availability[bookId] = false;
        }
      }
    } catch (e) {
      print('Error checking book availability: $e');
      // Return all as unavailable on error
      for (final bookId in bookIds) {
        availability[bookId] = false;
      }
    }
    
    return availability;
  }

  // Remove unavailable books from user's cart
  Future<bool> removeUnavailableFromCart(String userId, List<String> unavailableBookIds) async {
    try {
      final batch = _firestore.batch();
      
      for (final bookId in unavailableBookIds) {
        final cartQuery = await _firestore
            .collection('cart')
            .where('userId', isEqualTo: userId)
            .where('bookId', isEqualTo: bookId)
            .get();
        
        for (final doc in cartQuery.docs) {
          batch.delete(doc.reference);
        }
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error removing unavailable items from cart: $e');
      return false;
    }
  }

  // Generate unique order ID
  String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'COD${timestamp.toString().substring(timestamp.toString().length - 6)}$random';
  }

  // Get payment by ID
  Future<Payment?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();
      if (doc.exists) {
        return Payment.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting payment by ID: $e');
      return null;
    }
  }
}
