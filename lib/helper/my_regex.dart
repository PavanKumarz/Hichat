class MyRegex {
  //At least 8 characters at least one letter one number and one special character
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Standard email validation
  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static bool isValidPassword(String password) {
    return passwordRegex.hasMatch(password);
  }

  static bool isValidEmail(String email) {
    return emailRegex.hasMatch(email);
  }
}
