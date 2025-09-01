import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import '../services/payment_service.dart';

class CartViewModel extends ChangeNotifier {
  final CartService _cartService = CartService();
  
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get cartCount => _cartItems.length;
  
  // Calculate subtotal for trading platform (no quantities)
  double get subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.price);
  }
  
  // Calculate total with delivery
  double calculateTotalWithDelivery(String deliveryCity) {
    return _cartService.calculateTotal(_cartItems, deliveryCity);
  }
  
  // Get delivery fee
  double getDeliveryFee(String deliveryCity) {
    return _cartService.calculateDeliveryFee(deliveryCity);
  }
  
  // Load cart items for user
  void loadCartItems(String userId) {
    _cartService.getCartItems(userId).listen(
      (items) {
        _cartItems = items;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load cart items: $error';
        notifyListeners();
      },
    );
  }
  
  // Add item to cart
  Future<bool> addToCart(CartItem cartItem) async {
    _setLoading(true);
    
    try {
      // Optimistic update
      final existingIndex = _cartItems.indexWhere(
        (item) => item.bookId == cartItem.bookId,
      );
      
      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity += 1;
      } else {
        _cartItems.add(cartItem);
      }
      notifyListeners();
      
      final success = await _cartService.addToCart(cartItem);
      
      if (!success) {
        // Revert optimistic update
        if (existingIndex != -1) {
          _cartItems[existingIndex].quantity -= 1;
        } else {
          _cartItems.removeLast();
        }
        _errorMessage = 'Failed to add item to cart';
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error adding to cart: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Remove item from cart
  Future<bool> removeFromCart(String cartItemId) async {
    _setLoading(true);
    
    try {
      // Find item for optimistic update
      final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
      CartItem? removedItem;
      
      if (itemIndex != -1) {
        removedItem = _cartItems[itemIndex];
        _cartItems.removeAt(itemIndex);
        notifyListeners();
      }
      
      final success = await _cartService.removeFromCart(cartItemId);
      
      if (!success && removedItem != null) {
        // Revert optimistic update
        _cartItems.insert(itemIndex, removedItem);
        _errorMessage = 'Failed to remove item from cart';
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error removing from cart: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update quantity
  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    try {
      // Find item for optimistic update
      final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
      int? oldQuantity;
      
      if (itemIndex != -1) {
        oldQuantity = _cartItems[itemIndex].quantity;
        if (quantity <= 0) {
          _cartItems.removeAt(itemIndex);
        } else {
          _cartItems[itemIndex].quantity = quantity;
        }
        notifyListeners();
      }
      
      final success = await _cartService.updateCartItemQuantity(cartItemId, quantity);
      
      if (!success && oldQuantity != null) {
        // Revert optimistic update
        if (quantity <= 0 && itemIndex != -1) {
          // For reverting deletion, we'd need to store the original item
          // For now, just reload the cart items
          _errorMessage = 'Failed to update quantity';
        } else if (itemIndex != -1) {
          _cartItems[itemIndex].quantity = oldQuantity;
        }
        _errorMessage = 'Failed to update quantity';
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error updating quantity: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Clear cart
  Future<bool> clearCart(String userId) async {
    _setLoading(true);
    
    try {
      // Optimistic update
      final oldItems = List<CartItem>.from(_cartItems);
      _cartItems.clear();
      notifyListeners();
      
      final success = await _cartService.clearCart(userId);
      
      if (!success) {
        // Revert optimistic update
        _cartItems = oldItems;
        _errorMessage = 'Failed to clear cart';
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error clearing cart: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Place order
  Future<String?> placeOrder(Order order) async {
    _setLoading(true);
    
    try {
      final orderId = await _cartService.placeOrder(order);
      
      if (orderId != null) {
        _cartItems.clear();
        notifyListeners();
      } else {
        _errorMessage = 'Failed to place order';
        notifyListeners();
      }
      
      return orderId;
    } catch (e) {
      _errorMessage = 'Error placing order: $e';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Check if items in cart are still available
  Future<Map<String, bool>> checkCartAvailability() async {
    final paymentService = PaymentService();
    final bookIds = _cartItems.map((item) => item.bookId).toList();
    return await paymentService.checkBooksAvailability(bookIds);
  }

  // Remove unavailable items from cart
  Future<bool> removeUnavailableItems(String userId, List<String> unavailableBookIds) async {
    final paymentService = PaymentService();
    return await paymentService.removeUnavailableFromCart(userId, unavailableBookIds);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
