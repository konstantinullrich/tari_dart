import 'dart:ffi';

import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.freeze.g.dart';
import 'package:tari/src/utils/pointer_char_extension.dart';

class FFICompletedTxKernel extends FFIBase<TariTransactionKernel> {
  FFICompletedTxKernel(Pointer<TariTransactionKernel> pointer) {
    this.pointer = pointer;
  }

  String getExcess() => runWithError((errorPtr) =>
      lib.transaction_kernel_get_excess_hex(pointer, errorPtr).toDartString()!);

  String getExcessPublicNonce() => runWithError((errorPtr) => lib
      .transaction_kernel_get_excess_public_nonce_hex(pointer, errorPtr)
      .toDartString()!);

  String getExcessSignature() => runWithError((errorPtr) => lib
      .transaction_kernel_get_excess_signature_hex(pointer, errorPtr)
      .toDartString()!);

  @override
  void destroy() => lib.transaction_kernel_destroy(pointer);
}
