import 'dart:ffi';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.g.dart';

/// Wrapper for native byte vector type.
class FFIByteVector extends FFIBase<ByteVector> {
  FFIByteVector(Pointer<ByteVector> pointer) {
    this.pointer = pointer;
  }

  // constructor(bytes: ByteArray) : this() {
  // runWithError { jniCreate(bytes, it) }
  // }

  int getAt(int index) => runWithError(
      (errorPtr) => lib.byte_vector_get_at(pointer, index, errorPtr));

  int getLength() => runWithError(
      (errorPtr) => lib.byte_vector_get_length(pointer, errorPtr));

  Uint8List asByteArray() {
    final length = getLength();
    final byteArray = Uint8List(length);
    for (var i = 0; i < length; i++) {
      byteArray[i] = getAt(i);
    }
    return byteArray;
  }

  // String base58() => Base58Encoder.encode(this).base58;

  String toHex() => hex.encode(asByteArray());

  @override
  String toString() => toHex();

  @override
  void destroy() => lib.byte_vector_destroy(pointer);
}
