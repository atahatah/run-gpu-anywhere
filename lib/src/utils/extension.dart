extension ShouldEndWith on String {
  String shouldEndWith(String suffix) {
    if (!endsWith(suffix)) {
      return this + suffix;
    }
    return this;
  }
}
