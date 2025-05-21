import 'dart:ffi';

/// Base class for FFI native peer entities.
/// Extended by all model classes.
abstract class FFIBase<T extends NativeType> {
  Pointer<T> pointer = nullptr;

  void destroy();

  void finalize() {
    if (pointer != nullptr) destroy();
  }
}

/// Base class for FFI iterable entities. Used for proper memory management.
abstract class FFIIterableBase<T, N extends NativeType> extends FFIBase<N> {
  int getLength();

  T getAt(int index);

  List<T> toListAndDestroy() {
    final results = <T>[];
    for (var i = 0; i < getLength(); i++) {
      results.add(getAt(i));
    }
    destroy();
    return results;
  }
}
