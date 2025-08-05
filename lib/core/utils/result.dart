class Result<T> {
  final T? data;
  final String? error;

  Result._({this.data, this.error});

  static Result<T> success<T>(T data) => Result._(data: data);
  static Result<T> failure<T>(String message) => Result._(error: message);

  bool get isSuccess => data != null;
  bool get isFailure => error != null;
}
