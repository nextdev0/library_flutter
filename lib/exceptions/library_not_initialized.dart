class LibraryNotInitializedException implements Exception {
  @override
  String toString() => ''
      'Library has not been initialized. '
      'Please define [LibraryInitializer] at the top level of the widget '
      'to initialize it.'
      '';
}
