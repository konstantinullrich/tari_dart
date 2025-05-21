import 'dart:ffi';

import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.g.dart';

/// Wrapper for the native balance type.
class FFIBalance extends FFIBase<TariBalance> {
  FFIBalance(Pointer<TariBalance> pointer) {
    this.pointer = pointer;
  }

  int getAvailable() =>
      runWithError((errorPtr) => lib.balance_get_available(pointer, errorPtr));

  int getIncoming() => runWithError(
      (errorPtr) => lib.balance_get_pending_incoming(pointer, errorPtr));

  int getOutgoing() => runWithError(
      (errorPtr) => lib.balance_get_pending_outgoing(pointer, errorPtr));

  int getTimeLocked() => runWithError(
      (errorPtr) => lib.balance_get_time_locked(pointer, errorPtr));

  @override
  void destroy() => lib.balance_destroy(pointer);
}
