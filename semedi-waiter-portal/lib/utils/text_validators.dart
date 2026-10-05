class TextValidators {
  static String? fieldRequired(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  static String? match(
    String? value1,
    String? value2,
  ) {
    if (value1 == null || value1.isEmpty || value2 == null || value2.isEmpty) {
      return "This field is required";
    }
    if (value1 != value2) {
      return "Must Match";
    }
    return null;
  }

  static String? mustBe4Digits(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    if (value.length < 6) {
      return "Must be atleast 6 digits";
    }
    return null;
  }
}
