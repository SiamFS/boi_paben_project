import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart' as cart_models;

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add item to cart
  Future<bool> addToCart(cart_models.CartItem cartItem) async {
    try {
      // Check if item already exists in cart
      final existingItem = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: cartItem.userId)
          .where('bookId', isEqualTo: cartItem.bookId)
          .get();

      if (existingItem.docs.isNotEmpty) {
        // Item already exists, update quantity
        final docId = existingItem.docs.first.id;
        final currentQuantity = existingItem.docs.first.data()['quantity'] ?? 1;
        await _firestore.collection('cart').doc(docId).update({
          'quantity': currentQuantity + 1,
        });
      } else {
        // Add new item
        await _firestore.collection('cart').add(cartItem.toJson());
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get cart items for user
  Stream<List<cart_models.CartItem>> getCartItems(String userId) {
    return _firestore
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => cart_models.CartItem.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get cart count for user
  Stream<int> getCartCount(String userId) {
    return _firestore
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Remove item from cart
  Future<bool> removeFromCart(String cartItemId) async {
    try {
      await _firestore.collection('cart').doc(cartItemId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update cart item quantity
  Future<bool> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        return await removeFromCart(cartItemId);
      }
      await _firestore.collection('cart').doc(cartItemId).update({
        'quantity': quantity,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear cart
  Future<bool> clearCart(String userId) async {
    try {
      final cartItems = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Calculate delivery fee based on city
  double calculateDeliveryFee(String city) {
    final dhakaCities = [
      'dhaka', 'dhanmondi', 'gulshan', 'banani', 'uttara', 'mirpur', 
      'dhanmondi', 'motijheel', 'ramna', 'tejgaon', 'wari', 'old dhaka'
    ];
    
    return dhakaCities.any((dhakaCity) => 
        city.toLowerCase().contains(dhakaCity)) ? 60.0 : 100.0;
  }

  // Calculate total amount including delivery
  double calculateTotal(List<cart_models.CartItem> cartItems, String deliveryCity) {
    double total = 0;
    for (var item in cartItems) {
      total += item.price * item.quantity;
    }
    
    // Add delivery fee based on city
    double deliveryFee = calculateDeliveryFee(deliveryCity);
    return total + deliveryFee;
  }

  // Place order
  Future<String?> placeOrder(cart_models.Order order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toJson());
      
      // Clear cart after successful order
      await clearCart(order.userId);
      
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Get user orders
  Stream<List<cart_models.Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => cart_models.Order.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
