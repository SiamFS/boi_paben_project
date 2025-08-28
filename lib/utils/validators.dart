class PasswordValidator {
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }
  
  // Simple password validation for login (less strict)
  static String? validateLogin(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  
  static List<PasswordCriteria> getPasswordCriteria(String password) {
    return [
      PasswordCriteria(
        'At least 8 characters',
        password.length >= 8,
      ),
      PasswordCriteria(
        'One uppercase letter',
        password.contains(RegExp(r'[A-Z]')),
      ),
      PasswordCriteria(
        'One lowercase letter',
        password.contains(RegExp(r'[a-z]')),
      ),
      PasswordCriteria(
        'One number',
        password.contains(RegExp(r'[0-9]')),
      ),
      PasswordCriteria(
        'One special character',
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      ),
    ];
  }
}

class PasswordCriteria {
  final String text;
  final bool isValid;
  
  PasswordCriteria(this.text, this.isValid);
}

class EmailValidator {
  static String? validate(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    // Enhanced email validation with better regex
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Additional email validation for specific checks
  static bool isValidEmailFormat(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }
}

class NameValidator {
  static String? validate(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    
    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    // Check for valid name characters (letters, spaces, dots, hyphens)
    final nameRegex = RegExp(r'^[a-zA-Z\s\.\-]+$');
    if (!nameRegex.hasMatch(name.trim())) {
      return 'Name can only contain letters, spaces, dots, and hyphens';
    }
    
    return null;
  }
}

class PhoneValidator {
  static String? validate(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and hyphens for validation
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    
    // Validate Bangladeshi phone number format
    final phoneRegex = RegExp(r'^(\+88|88)?(01[3-9]\d{8})$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Please enter a valid Bangladeshi phone number';
    }
    
    return null;
  }
}

class PriceValidator {
  static String? validate(String? price) {
    if (price == null || price.isEmpty) {
      return 'Price is required';
    }
    
    final priceValue = double.tryParse(price);
    if (priceValue == null || priceValue <= 0) {
      return 'Please enter a valid price greater than 0';
    }
    
    if (priceValue > 100000) {
      return 'Price cannot exceed ৳100,000';
    }
    
    return null;
  }
}

class ZipCodeValidator {
  static String? validate(String? zipCode) {
    if (zipCode == null || zipCode.isEmpty) {
      return 'Zip code is required';
    }
    
    // Validate 4-digit zip code for Bangladesh
    final zipRegex = RegExp(r'^\d{4}$');
    if (!zipRegex.hasMatch(zipCode)) {
      return 'Please enter a valid 4-digit zip code';
    }
    
    return null;
  }
}

class EditionValidator {
  static String? validate(String? edition) {
    if (edition == null || edition.isEmpty) {
      return null; // Edition is optional
    }
    
    // Validate edition format (1, 2nd, 3rd, etc.)
    final editionRegex = RegExp(r'^(\d{1,2}(st|nd|rd|th)?|\d+)$', caseSensitive: false);
    if (!editionRegex.hasMatch(edition.trim())) {
      return 'Please enter a valid edition (e.g., 1, 2nd, 3rd)';
    }
    
    return null;
  }
}

class GeneralValidator {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    return null;
  }
  
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }
  
  static String? validatePasswordMatch(String? confirmPassword, String? originalPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
