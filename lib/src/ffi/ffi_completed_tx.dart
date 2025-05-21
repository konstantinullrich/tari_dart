import 'dart:ffi';

import 'package:tari/ffi.dart';
import 'package:tari/src/ffi/ffi_tx_base.dart';
import 'package:tari/src/generated_bindings_tari.g.dart';
import 'package:tari/src/utils/pointer_char_extension.dart';
import 'package:tari/src/utils/uint64_to_bigint.dart';

class FFICompletedTx extends FFITxBase<TariCompletedTransaction> {
  FFICompletedTx(Pointer<TariCompletedTransaction> pointer) {
    this.pointer = pointer;
  }

  @override
  void destroy() => lib.completed_transaction_destroy(pointer);

  String getId() => runWithError((errorPtr) => uint64ToBigInt(
          lib.completed_transaction_get_transaction_id(pointer, errorPtr))
      .toRadixString(16));

  @override
  FFITariWalletAddress getDestinationPublicKey() =>
      runWithError((errorPtr) => FFITariWalletAddress(
          lib.completed_transaction_get_destination_tari_address(
              pointer, errorPtr)));

  @override
  FFITariWalletAddress getSourcePublicKey() =>
      runWithError((errorPtr) => FFITariWalletAddress(lib
          .completed_transaction_get_source_tari_address(pointer, errorPtr)));

  BigInt getAmount() => runWithError((errorPtr) =>
      uint64ToBigInt(lib.completed_transaction_get_amount(pointer, errorPtr)));

  BigInt getFee() => runWithError((errorPtr) =>
      uint64ToBigInt(lib.completed_transaction_get_fee(pointer, errorPtr)));

  BigInt getTimestamp() => runWithError((errorPtr) => uint64ToBigInt(
      lib.completed_transaction_get_timestamp(pointer, errorPtr)));

  String getPaymentId() => runWithError((errorPtr) => lib
      .completed_transaction_get_payment_id(pointer, errorPtr)
      .toDartString()!);

  int getStatus() => runWithError(
      (errorPtr) => lib.completed_transaction_get_status(pointer, errorPtr));

  BigInt getConfirmationCount() => runWithError((errorPtr) => uint64ToBigInt(
      lib.completed_transaction_get_confirmations(pointer, errorPtr)));

  @override
  bool isOutbound() => runWithError(
      (errorPtr) => lib.completed_transaction_is_outbound(pointer, errorPtr));

  int getCancellationReason() => runWithError((errorPtr) =>
      lib.completed_transaction_get_cancellation_reason(pointer, errorPtr));

  FFICompletedTxKernel getTransactionKernel() =>
      runWithError((errorPtr) => FFICompletedTxKernel(
          lib.completed_transaction_get_transaction_kernel(pointer, errorPtr)));
}
