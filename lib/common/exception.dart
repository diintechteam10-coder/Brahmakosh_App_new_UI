class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
}

class InvalidInputException implements Exception {
  final String message;
  InvalidInputException(this.message);
}

class UnauthorisedException implements Exception {
  final String message;
  UnauthorisedException(this.message);
}

class FetchDataException implements Exception {
  final String message;
  FetchDataException(this.message);
}
