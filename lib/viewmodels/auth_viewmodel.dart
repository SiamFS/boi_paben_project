import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  
  String? _savedStreetAddress;
  String? _savedCityTown;
  String? _savedDistrict;
  String? _savedZipCode;
  String? _savedContactNumber;
  bool _autoFillEnabled = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  String? get savedStreetAddress => _savedStreetAddress;
  String? get savedCityTown => _savedCityTown;
  String? get savedDistrict => _savedDistrict;
  String? get savedZipCode => _savedZipCode;
  String? get savedContactNumber => _savedContactNumber;
  bool get autoFillEnabled => _autoFillEnabled;

  AuthViewModel() {
    _initializeAuth();
    _authService.authStateChanges.listen((user) {
      if (user == null) {
        _user = null;
        _clearSavedCredentials();
      }
      notifyListeners();
    });
  }

  Future<void> _initializeAuth() async {
    _isInitialized = false;
    await _loadSavedCredentials();
    await _loadUserAddress();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedPassword = prefs.getString('user_password');
    
    if (savedEmail != null && savedPassword != null) {
      try {
        _user = await _authService.signInWithEmailAndPassword(
          email: savedEmail,
          password: savedPassword,
        );
      } catch (e) {
        await _clearSavedCredentials();
      }
    }
  }

  Future<void> _loadUserAddress() async {
    final prefs = await SharedPreferences.getInstance();
    _savedStreetAddress = prefs.getString('saved_street_address');
    _savedCityTown = prefs.getString('saved_city_town');
    _savedDistrict = prefs.getString('saved_district');
    _savedZipCode = prefs.getString('saved_zip_code');
    _savedContactNumber = prefs.getString('saved_contact_number');
    _autoFillEnabled = prefs.getBool('auto_fill_enabled') ?? true;
  }

  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_password');
  }

  Future<void> saveUserAddress({
    required String streetAddress,
    required String cityTown,
    required String district,
    required String zipCode,
    required String contactNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_street_address', streetAddress);
    await prefs.setString('saved_city_town', cityTown);
    await prefs.setString('saved_district', district);
    await prefs.setString('saved_zip_code', zipCode);
    await prefs.setString('saved_contact_number', contactNumber);
    
    _savedStreetAddress = streetAddress;
    _savedCityTown = cityTown;
    _savedDistrict = district;
    _savedZipCode = zipCode;
    _savedContactNumber = contactNumber;
    notifyListeners();
  }

  Future<void> toggleAutoFill(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_fill_enabled', enabled);
    _autoFillEnabled = enabled;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (_user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_password', password);
      }

      return _user != null;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_password', password);
      }

      return _user != null;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }


  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
      await _clearSavedCredentials();
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  String _getErrorMessage(String error) {
    
    if (error.contains('user-not-found')) {
      return 'No account found with this email address. Please check your email or sign up.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('invalid-credential')) {
      return 'Invalid email or password. Please check your credentials.';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email address. Please sign in instead.';
    } else if (error.contains('weak-password')) {
      return 'The password is too weak. Please use at least 8 characters with uppercase, lowercase, numbers, and special characters.';
    } else if (error.contains('invalid-email')) {
      return 'The email address is not valid. Please enter a correct email format.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please wait a moment before trying again.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Email/password sign in is not enabled. Please contact support.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.contains('requires-recent-login')) {
      return 'Please sign out and sign back in to perform this action.';
    } else {
      return 'An unexpected error occurred. Please try again or contact support if the problem persists.';
    }
  }
}
