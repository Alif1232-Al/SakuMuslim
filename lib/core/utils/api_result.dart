/// A sealed class hierarchy for handling API responses.
/// This ensures all API calls return either a success or failure.
sealed class ApiResult<T> {
  const ApiResult();

  /// Pattern matching helper
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
  }) {
    return switch (this) {
      ApiSuccess<T> s => success(s.data),
      ApiFailure<T> f => failure(f.message, f.statusCode),
    };
  }

  /// Check if result is success
  bool get isSuccess => this is ApiSuccess<T>;

  /// Check if result is failure
  bool get isFailure => this is ApiFailure<T>;

  /// Get data or null
  T? get dataOrNull => switch (this) {
        ApiSuccess<T> s => s.data,
        ApiFailure<T> _ => null,
      };

  /// Get message or null
  String? get messageOrNull => switch (this) {
        ApiSuccess<T> _ => null,
        ApiFailure<T> f => f.message,
      };
}

/// Represents a successful API response
class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);

  @override
  String toString() => 'ApiSuccess(data: $data)';
}

/// Represents a failed API response
class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final dynamic error;

  const ApiFailure(this.message, {this.statusCode, this.error});

  @override
  String toString() =>
      'ApiFailure(message: $message, statusCode: $statusCode)';
}

/// Extension for easier result handling
extension ApiResultExtension<T> on ApiResult<T> {
  /// Get data or throw error
  T get dataOrThrow {
    return switch (this) {
      ApiSuccess<T> s => s.data,
      ApiFailure<T> f => throw Exception(f.message),
    };
  }

  /// Get data or return default
  T dataOrElse(T defaultValue) {
    return switch (this) {
      ApiSuccess<T> s => s.data,
      ApiFailure<T> _ => defaultValue,
    };
  }

  /// Map success data to another type
  ApiResult<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      ApiSuccess<T> s => ApiSuccess(transform(s.data)),
      ApiFailure<T> f => ApiFailure(f.message, statusCode: f.statusCode),
    };
  }

  /// Handle result with callbacks
  void handle({
    Function(T data)? onSuccess,
    Function(String message, int? statusCode)? onFailure,
  }) {
    switch (this) {
      case ApiSuccess<T> s:
        onSuccess?.call(s.data);
      case ApiFailure<T> f:
        onFailure?.call(f.message, f.statusCode);
    }
  }
}
