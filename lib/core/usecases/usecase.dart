/// Flux Application - Base Use Case
///
/// Abstract interface for all use cases in the domain layer.
library;

/// A use case contract that takes [Params] and returns [Type].
///
/// Every domain use case should implement this interface to
/// ensure a consistent calling convention across features.
abstract class UseCase<T, Params> {
  /// Executes the use case with the given [params].
  Future<T> call(Params params);
}

/// Marker class for use cases that do not require parameters.
class NoParams {
  const NoParams();
}
