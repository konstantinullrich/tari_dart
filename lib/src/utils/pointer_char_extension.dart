import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tari/ffi.dart';

extension CStringUtil on Pointer<Char> {
  bool get isNull => address == nullptr.address;

  void free() => lib.string_destroy(this);

  String? toDartString() {
    if (isNull) return null;

    final str = cast<Utf8>().toDartString();
    free();
    return str;
  }
}

extension GetIntAndFree on Pointer<Int> {
  void free() => lib.free(this as Pointer<Void>);

  int toInt() {
    final val = value;
    free();
    return val;
  }
}
