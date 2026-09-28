// Form validation utilities for email, password, and other inputs
class Validators {
  Validators._();

  // EMAIL VALIDATION

  // Email regex pattern - RFC 5322 compliant (simplified)
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Validate email format
  // Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    // Additional checks
    if (email.length > 254) {
      return 'Email is too long';
    }

    return null; // Valid
  }

  // Check if email is valid (boolean)
  static bool isValidEmail(String? value) {
    return validateEmail(value) == null;
  }

  // PASSWORD VALIDATION

  // Password requirements:
  // - Minimum 8 characters
  // - At least 1 uppercase letter
  // - At least 1 digit
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!_hasUpperCase(value)) {
      return 'Password must contain at least 1 uppercase letter';
    }

    if (!_hasDigit(value)) {
      return 'Password must contain at least 1 digit';
    }

    return null; // Valid
  }

  // Check if password is strong enough (boolean)
  static bool isValidPassword(String? value) {
    return validatePassword(value) == null;
  }

  // Validate password confirmation
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmation) {
      return 'Passwords do not match';
    }

    return null; // Valid
  }

  // Check password strength level (0-4)
  // 0 = very weak, 1 = weak, 2 = fair, 3 = good, 4 = strong
  static int getPasswordStrength(String? value) {
    if (value == null || value.isEmpty) return 0;

    int strength = 0;

    // Length
    if (value.length >= 8) strength++;
    if (value.length >= 12) strength++;

    // Complexity
    if (_hasUpperCase(value)) strength++;
    if (_hasLowerCase(value)) strength++;
    if (_hasDigit(value)) strength++;
    if (_hasSpecialChar(value)) strength++;

    // Cap at 4
    return strength > 4 ? 4 : strength;
  }

  // DISPLAY NAME VALIDATION

  // Validate display name
  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }

    final name = value.trim();

    if (name.length < 2) {
      return 'Display name must be at least 2 characters';
    }

    if (name.length > 50) {
      return 'Display name is too long';
    }

    // Only allow letters, spaces, and common punctuation
    if (!RegExp(r"^[a-zA-Z\s\-'.]+$").hasMatch(name)) {
      return 'Display name contains invalid characters';
    }

    return null; // Valid
  }

  // GENERIC VALIDATION

  // Validate required field (not empty)
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }

    return null;
  }

  // Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value == null) return null;

    if (value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be at most $maxLength characters';
    }

    return null;
  }

  // Validate length range
  static String? validateLengthRange(
    String? value,
    int minLength,
    int maxLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < minLength || value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be between $minLength and $maxLength characters';
    }

    return null;
  }

  // HELPER METHODS

  static bool _hasUpperCase(String value) {
    return value.contains(RegExp(r'[A-Z]'));
  }

  static bool _hasLowerCase(String value) {
    return value.contains(RegExp(r'[a-z]'));
  }

  static bool _hasDigit(String value) {
    return value.contains(RegExp(r'[0-9]'));
  }

  static bool _hasSpecialChar(String value) {
    return value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  // COMBINE VALIDATORS

  // Combine multiple validators into one
  // Returns first error or null if all pass
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
