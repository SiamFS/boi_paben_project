import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import '../models/cart_model.dart';
import '../services/payment_service.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  SalesData? _salesData;
  List<Payment> _buyerPayments = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  SalesData? get salesData => _salesData;
  List<Payment> get buyerPayments => _buyerPayments;
  
  // Load seller sales data
  Future<void> loadSellerSalesData(String sellerEmail) async {
    _setLoading(true);
    try {
      _salesData = await _paymentService.getSellerSalesData(sellerEmail);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to load sales data: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  // Load buyer payments
  void loadBuyerPayments(String buyerId) {
    _paymentService.getBuyerPayments(buyerId).listen(
      (payments) {
        _buyerPayments = payments;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load purchase history: $error';
        notifyListeners();
      },
    );
  }
  
  // Update payment status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    try {
      final success = await _paymentService.updatePaymentStatus(paymentId, status);
      if (success) {
        // Update local data
        final index = _buyerPayments.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          _buyerPayments[index] = _buyerPayments[index].copyWith(status: status);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update payment status: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Check books availability
  Future<Map<String, bool>> checkBooksAvailability(List<String> bookIds) async {
    try {
      return await _paymentService.checkBooksAvailability(bookIds);
    } catch (e) {
      _errorMessage = 'Failed to check book availability: $e';
      notifyListeners();
      return {};
    }
  }
  
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
    _setLoading(true);
    try {
      final paymentId = await _paymentService.processCODPayment(
        buyerId: buyerId,
        buyerEmail: buyerEmail,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        deliveryAddress: deliveryAddress,
        city: city,
        district: district,
        zipCode: zipCode,
        cartItems: cartItems,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        notes: notes,
      );
      
      if (paymentId != null) {
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to process payment';
      }
      
      return paymentId;
    } catch (e) {
      _errorMessage = 'Error processing payment: $e';
      return null;
    } finally {
      _setLoading(false);
    }
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
