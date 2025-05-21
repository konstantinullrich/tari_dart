import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:tari/src/ffi/ffi_tari_transport_config.dart';
import 'package:tari/src/generated_bindings_tari.freeze.g.dart';
import 'package:tari/tari.dart';

import 'callback.dart';

typedef CallbackReceivedTransaction = Void Function(
    Pointer<Void>, Pointer<TariPendingInboundTransaction>);
typedef CallbackConnectivityStatus = Void Function(Pointer<Void>, Uint64);

Future<void> main2() async {
  final transport = FFITariTransportConfig.tcp("/ip4/62.216.208.189/tcp/9051");
  final comms = getWalletConfig(path: "./wallet", transport: transport);

  final wallet = createWallet(
    commsConfig: comms,
    logPath: "./wallet/logs/wallet.log",
    logLevel: 11,
    passphrase: '',
    callbackReceivedTransaction: CallbackPlaceholders.callbackReceivedTransaction,
    callbackReceivedTransactionReply: CallbackPlaceholders.callbackReceivedTransactionReply,
    callbackReceivedFinalizedTransaction: CallbackPlaceholders.callbackReceivedFinalizedTransaction,
    callbackReceivedTransactionBroadcast: CallbackPlaceholders.callbackTransactionBroadcast,
    callbackReceivedTransactionMined: CallbackPlaceholders.callbackTransactionMined,
    callbackReceivedTransactionMinedUnconfirmed: CallbackPlaceholders.callbackTransactionMinedUnconfirmed,
    callbackFauxTransactionMinedConfirmed: CallbackPlaceholders.callbackFauxTransactionConfirmed,
    callbackFauxTransactionMinedUnconfirmed: CallbackPlaceholders.callbackFauxTransactionUnconfirmed,
    callbackTransactionSendResult: CallbackPlaceholders.callbackTransactionSendResult,
    callbackTransactionCancellation: CallbackPlaceholders.callbackTransactionCancellation,
    callbackTxoValidationComplete: CallbackPlaceholders.callbackTxoValidationComplete,
    callbackContactsLivenessDataUpdated: CallbackPlaceholders.callbackContactsLivenessDataUpdated,
    callbackBalanceUpdated: CallbackPlaceholders.callbackBalanceUpdated,
    callbackTransactionValidationComplete: CallbackPlaceholders.callbackTransactionValidationComplete,
    callbackSafMessagesReceived: CallbackPlaceholders.callbackSafMessagesReceived,
    callbackConnectivityStatus: CallbackPlaceholders.callbackConnectivityStatus,
    callbackWalletScannedHeight: CallbackPlaceholders.callbackWalletScannedHeight,
    callbackBaseNodeState: CallbackPlaceholders.callbackBaseNodeState,
    dnsSeeds: "seeds.tari.com",
    mnemonic: 'park snow bring damp venture palm rocket cactus hole hunt save broken swallow coach state relief census pride penalty sound jazz romance obvious canyon'
  );

  final sw = wallet.getMnemonic();
  print(sw);

  final address = wallet.getEmojiID();

  print(address.emojiId);
  print(address.base58);

  wallet.startRecovery((_, __, ___, ____) {});

  print(wallet.isRecovering());

  final name = stdin.readLineSync();

  final balance = wallet.getBalance();
  print(balance.available);

}



Future<void> main() async {
  Isolate.run(main2);
}
