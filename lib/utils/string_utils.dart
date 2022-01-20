extension StringUtils on String {
  bool get isTrimEmpty {
    return trim().isEmpty;
  }

  bool get isNotTrimEmpty {
    return trim().isNotEmpty;
  }
}
