class HandlingException implements Exception {
  String message;
  HandlingException({required this.message});

  @override
  String toString() {
    // TODO: implement toString
    return message;
  }
}
