enum AppErrorType {
  network,
  timeout,
  unauthorized,
  http,
  parse,
  unknown,
}

class AppError implements Exception {
  final AppErrorType type;
  final String message;
  final int? statusCode;
  final Object? cause;
  final StackTrace? stackTrace;
  AppError(this.type, this.message, {this.statusCode, this.cause, this.stackTrace});
  factory AppError.network(String message, {Object? cause, StackTrace? stackTrace}) {
    return AppError(AppErrorType.network, message, cause: cause, stackTrace: stackTrace);
  }

  factory AppError.timeout(String message, {Object? cause, StackTrace? stackTrace}) {
    return AppError(AppErrorType.timeout, message, cause: cause, stackTrace: stackTrace);
  }

  factory AppError.unauthorized(String message, {int? statusCode, Object? cause, StackTrace? stackTrace}) {
    return AppError(AppErrorType.unauthorized, message, statusCode: statusCode, cause: cause, stackTrace: stackTrace);
  }

  factory AppError.http(String message, {int? statusCode, Object? cause, StackTrace? stackTrace}) {
    return AppError(AppErrorType.http, message, statusCode: statusCode, cause: cause, stackTrace: stackTrace);
  }

  factory AppError.parse(String message, {Object? cause, StackTrace? stackTrace}) {
    return AppError(AppErrorType.parse, message, cause: cause, stackTrace: stackTrace);
  }

  factory AppError.unknown(String message, {Object? cause, StackTrace? stackTrace}) {
    return AppError(AppErrorType.unknown, message, cause: cause, stackTrace: stackTrace);
  }

  @override
  String toString() {
    return message;
  }
}

