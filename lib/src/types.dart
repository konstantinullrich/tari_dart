import 'dart:ffi';

import 'package:tari/src/generated_bindings_tari.g.dart';

typedef CallbackReceivedTransaction = void Function(Pointer<Void>, Pointer<TariPendingInboundTransaction>);
typedef CallbackReceivedTransactionReply = void Function(Pointer<Void>, Pointer<TariCompletedTransaction>);
typedef CallbackReceivedFinalizedTransaction = void Function(Pointer<Void>, Pointer<TariCompletedTransaction>);
typedef CallbackReceivedTransactionBroadcast = void Function(Pointer<Void>, Pointer<TariCompletedTransaction>);
typedef CallbackReceivedTransactionMined = void Function(Pointer<Void>, Pointer<TariCompletedTransaction>);
typedef CallbackReceivedTransactionMinedUnconfirmed = void Function(Pointer<Void>, Pointer<TariCompletedTransaction>, int);
typedef CallbackFauxTransactionMinedConfirmed = void Function(Pointer<Void>, Pointer<TariCompletedTransaction>);
typedef CallbackFauxTransactionMinedUnconfirmed = void Function(Pointer<Void>, Pointer<TariCompletedTransaction>, int);
typedef CallbackTransactionSendResult = void Function(Pointer<Void>, int, Pointer<TariTransactionSendStatus>);
typedef CallbackTransactionCancellation = void Function(Pointer<Void>, Pointer<TariCompletedTransaction>, int);
typedef CallbackTxoValidationComplete = void Function(Pointer<Void>, int, int);
typedef CallbackContactsLivenessDataUpdated = void Function(Pointer<Void>, Pointer<TariContactsLivenessData>);
typedef CallbackBalanceUpdated = void Function(Pointer<Void>, Pointer<TariBalance>);
typedef CallbackTransactionValidationComplete = void Function(Pointer<Void>, int, int);
typedef CallbackSafMessagesReceived = void Function(Pointer<Void> context);
typedef CallbackConnectivityStatus = void Function(Pointer<Void>, int);
typedef CallbackWalletScannedHeight = void Function(Pointer<Void>, int);
typedef CallbackBaseNodeState = void Function(Pointer<Void>, Pointer<TariBaseNodeState>);

typedef CallbackRecoveryProgress = void Function(Pointer<Void>, int, int, int);

typedef CallableReceivedTransaction = Void Function(Pointer<Void>, Pointer<TariPendingInboundTransaction>);
typedef CallableReceivedTransactionReply = Void Function(Pointer<Void>, Pointer<TariCompletedTransaction>);
typedef CallableReceivedFinalizedTransaction = Void Function(Pointer<Void>, Pointer<TariCompletedTransaction>);
typedef CallableReceivedTransactionBroadcast = Void Function(Pointer<Void>, Pointer<TariCompletedTransaction>);
typedef CallableReceivedTransactionMined = Void Function(Pointer<Void>, Pointer<TariCompletedTransaction>);
typedef CallableReceivedTransactionMinedUnconfirmed = Void Function(Pointer<Void>, Pointer<TariCompletedTransaction>, Uint64);
typedef CallableFauxTransactionMinedConfirmed = Void Function(Pointer<Void>, Pointer<TariCompletedTransaction>);
typedef CallableFauxTransactionMinedUnconfirmed = Void Function(Pointer<Void>, Pointer<TariCompletedTransaction>, Uint64);
typedef CallableTransactionSendResult = Void Function(Pointer<Void>, UnsignedLongLong, Pointer<TariTransactionSendStatus>);
typedef CallableTransactionCancellation = Void Function(Pointer<Void>, Pointer<TariCompletedTransaction>, Uint64);
typedef CallableTxoValidationComplete = Void Function(Pointer<Void>, Uint64, Uint64);
typedef CallableContactsLivenessDataUpdated = Void Function(Pointer<Void>, Pointer<TariContactsLivenessData>);
typedef CallableBalanceUpdated = Void Function(Pointer<Void>, Pointer<TariBalance>);
typedef CallableTransactionValidationComplete = Void Function(Pointer<Void>, Uint64, Uint64);
typedef CallableSafMessagesReceived = Void Function(Pointer<Void> context);
typedef CallableConnectivityStatus = Void Function(Pointer<Void>, Uint64);
typedef CallableWalletScannedHeight = Void Function(Pointer<Void>, Uint64);
typedef CallableBaseNodeState = Void Function(Pointer<Void>, Pointer<TariBaseNodeState>);

typedef CallableRecoveryProgress = Void Function(Pointer<Void>, Uint8, Uint64, Uint64);
