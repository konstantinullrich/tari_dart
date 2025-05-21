import 'dart:ffi';

import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.g.dart';

class FFICompletedTxs
    extends FFIIterableBase<FFICompletedTx, TariCompletedTransactions> {
  FFICompletedTxs(Pointer<TariCompletedTransactions> pointer) {
    this.pointer = pointer;
  }

  @override
  int getLength() => runWithError(
      (errorPtr) => lib.completed_transactions_get_length(pointer, errorPtr));

  @override
  FFICompletedTx getAt(int index) => runWithError((errorPtr) => FFICompletedTx(
      lib.completed_transactions_get_at(pointer, index, errorPtr)));

  @override
  void destroy() => lib.completed_transactions_destroy(pointer);
}
