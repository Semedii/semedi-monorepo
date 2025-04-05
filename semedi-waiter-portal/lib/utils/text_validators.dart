class TextValidators {
  static String? fieldRequired(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }
}
