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
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
}
