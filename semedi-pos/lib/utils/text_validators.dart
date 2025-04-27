class TextValidators {
  static String? fieldRequired(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  static String? onlyNumbers(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    } else if (int.tryParse(value) == null) {
      return "Please enter a valid whole number";
    }
    return null;
  }
}
