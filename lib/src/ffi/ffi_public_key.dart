import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.g.dart';
import 'package:tari/src/utils/pointer_char_extension.dart';

/// Wrapper for native public key type.
class FFIPublicKey extends FFIBase<TariPublicKey> {
  FFIPublicKey(Pointer<TariPublicKey> pointer) {
    this.pointer = pointer;
  }

  FFIPublicKey.fromBytes(FFIByteVector bytes) {
    pointer = runWithError(
        (errorPtr) => lib.public_key_create(bytes.pointer, errorPtr));
  }

  FFIPublicKey.fromHex(String hex) {
    final hexPtr = hex.toNativeUtf8().cast<Char>();
    pointer =
        runWithError((errorPtr) => lib.public_key_from_hex(hexPtr, errorPtr));
    hexPtr.free();
  }

  FFIByteVector getByteVector() => runWithError(
      (errorPtr) => FFIByteVector(lib.public_key_get_bytes(pointer, errorPtr)));

  String getEmojiId() => runWithError((errorPtr) =>
      lib.public_key_get_emoji_encoding(pointer, errorPtr).toDartString()!);

  @override
  String toString() => getByteVector().toHex();

  @override
  void destroy() => lib.public_key_destroy(pointer);
}
