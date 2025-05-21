import 'dart:ffi';

import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.freeze.g.dart';

/// Wrapper for native public key list type.
class FFIPublicKeys extends FFIBase<TariPublicKeys> {
  FFIPublicKeys(Pointer<TariPublicKeys> pointer) {
    this.pointer = pointer;
  }

  int getLength() =>
      runWithError((errorPtr) => lib.public_keys_get_length(pointer, errorPtr));

  FFIPublicKey getAt(int index) => runWithError((errorPtr) =>
      FFIPublicKey(lib.public_keys_get_at(pointer, index, errorPtr)));

  @override
  void destroy() => lib.public_keys_destroy(pointer);
}
