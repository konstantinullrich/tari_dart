import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:tari/ffi.dart';
import 'package:tari/src/ffi/ffi_tari_transport_config.dart';
import 'package:tari/src/generated_bindings_tari.freeze.g.dart';
import 'package:tari/tari.dart';

import 'callback.dart';

typedef CallbackReceivedTransaction = Void Function(
    Pointer<Void>, Pointer<TariPendingInboundTransaction>);
typedef CallbackConnectivityStatus = Void Function(Pointer<Void>, Uint64);

Future<void> main2(String? mnemonic) async {
  final transport = FFITariTransportConfig.tcp("/ip4/127.0.0.1/tcp/18183");
  final comms = getWalletConfig(path: "./wallet", transport: transport);

  final wallet = createWallet(
      commsConfig: comms,
      logPath: "./wallet/logs/wallet.log",
      logLevel: 2,
      passphrase: '',
      callbackReceivedTransaction:
          CallbackPlaceholders.callbackReceivedTransaction,
      callbackReceivedTransactionReply:
          CallbackPlaceholders.callbackReceivedTransactionReply,
      callbackReceivedFinalizedTransaction:
          CallbackPlaceholders.callbackReceivedFinalizedTransaction,
      callbackReceivedTransactionBroadcast:
          CallbackPlaceholders.callbackTransactionBroadcast,
      callbackReceivedTransactionMined:
          CallbackPlaceholders.callbackTransactionMined,
      callbackReceivedTransactionMinedUnconfirmed:
          CallbackPlaceholders.callbackTransactionMinedUnconfirmed,
      callbackFauxTransactionMinedConfirmed:
          CallbackPlaceholders.callbackFauxTransactionConfirmed,
      callbackFauxTransactionMinedUnconfirmed:
          CallbackPlaceholders.callbackFauxTransactionUnconfirmed,
      callbackTransactionSendResult:
          CallbackPlaceholders.callbackTransactionSendResult,
      callbackTransactionCancellation:
          CallbackPlaceholders.callbackTransactionCancellation,
      callbackTxoValidationComplete:
          CallbackPlaceholders.callbackTxoValidationComplete,
      callbackContactsLivenessDataUpdated:
          CallbackPlaceholders.callbackContactsLivenessDataUpdated,
      callbackBalanceUpdated: CallbackPlaceholders.callbackBalanceUpdated,
      callbackTransactionValidationComplete:
          CallbackPlaceholders.callbackTransactionValidationComplete,
      callbackSafMessagesReceived:
          CallbackPlaceholders.callbackSafMessagesReceived,
      callbackConnectivityStatus:
          CallbackPlaceholders.callbackConnectivityStatus,
      callbackWalletScannedHeight:
          CallbackPlaceholders.callbackWalletScannedHeight,
      callbackBaseNodeState: CallbackPlaceholders.callbackBaseNodeState,
      dnsSeeds: 'seeds.tari.com',
      mnemonic: mnemonic);

  var errorOut = malloc<Int>();
  lib.wallet_clear_value(
      wallet.wallet!, 'recovery_data'.toNativeUtf8().cast<Char>(), errorOut);
  malloc.free(errorOut);

  final sw = wallet.getMnemonic();
  print(sw);

  final address = wallet.getEmojiID();

  print(address.emojiId);
  print(address.base58);

  wallet.setBaseNode();
  await Future.delayed(
      Duration(seconds: 5)); // Give it time to connect to the base node

  print("Initial chain tip height: ${CallbackPlaceholders.chainTipHeight}");
  
  var isRecovering = true;
  wallet.startRecovery((_, event, arg1, arg2) {
    switch (event) {
      case 0:
        print("[Recovery] Connecting to base node...");
        break;
      case 1:
        print("[Recovery] Connection to base node established");
        break;
      case 2:
        print(
            "[Recovery] Connection to base node failed. Retry ${arg1}/${arg2}");
        break;
      case 3:
        print("[Recovery] Scanning progress: ${arg1}/${arg2} blocks");
        isRecovering = false;
        break;
      case 4:
        print(
            "[Recovery] Recovery completed! Recovered ${arg1} UTXOs (${arg2} MicroMinotari)");
        isRecovering = false;
        break;
      case 5:
        print("[Recovery] Scanning round failed. Retry ${arg1}/${arg2}");
        break;
      case 6:
        print("[Recovery] Recovery failed!");
        isRecovering = false;
        break;
      default:
        print("[Recovery] Unknown event: $event ${arg1} ${arg2}");
        break;
    }
  });
  await Future.delayed(Duration(seconds: 5)); // Give it time to scan the blocks

  // Monitor recovery process
  while (isRecovering) {
    await Future.delayed(Duration(seconds: 5)); // Check every 5 seconds
    final balance = wallet.getBalance();
    print(
        "[Main] Scanned height: ${CallbackPlaceholders.scannedHeight} / ${CallbackPlaceholders.chainTipHeight}");
    print(
        "Balance: ${balance.available} ${balance.pendingIncoming} ${balance.pendingOutgoing} ${balance.timeLocked}");
    if (CallbackPlaceholders.scannedHeight >=
            CallbackPlaceholders.chainTipHeight &&
        CallbackPlaceholders.chainTipHeight > 0) {
      break;
    }
  }
  print("Recovery process finished");

  final balance = wallet.getBalance();
  print(
      "Balance: ${balance.available} ${balance.pendingIncoming} ${balance.pendingOutgoing} ${balance.timeLocked}");
}

Future<void> main(List<String> arguments) async {
  String? mnemonic;
  if (arguments.isNotEmpty) {
    mnemonic = arguments[0];
  }
  Isolate.run(() => main2(mnemonic));
}
