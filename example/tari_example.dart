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
      mnemonic:
          'scare behind olive upon high buyer unusual frown robust resemble firm hundred excess supreme salon search same box peanut palm normal child pact upon');

  final sw = wallet.getMnemonic();
  print(sw);

  final address = wallet.getEmojiID();

  print(address.emojiId);
  print(address.base58);

  wallet.setBaseNode();
   await Future.delayed(Duration(seconds: 5)); // Check every 5 seconds


  wallet.startRecovery((_, event, arg1, arg2) {
    switch (event) {
      case 2:
        print("Connection to base node failed. Retry ${arg1}/${arg2}");
        break;
      case 3:
        print("Scanning progress: ${arg1}/${arg2} blocks");
        break;
      case 4:
        print(
            "Recovery completed! Recovered ${arg1} UTXOs (${arg2} MicroMinotari)");
        break;
      case 5:
        print("Scanning round failed. Retry ${arg1}/${arg2}");
        break;
      case 6:
        print("Recovery failed!");
        break;
    }
  });
   await Future.delayed(Duration(seconds: 5)); // Check every 5 seconds

  print(wallet.isRecovering());
  

  // Monitor recovery process
  while (wallet.isRecovering()) {
    await Future.delayed(Duration(seconds: 5)); // Check every 5 seconds
  }
  print("Recovery process finished");

  final balance = wallet.getBalance();
  print("Final balance: ${balance.available}");

  final name = stdin.readLineSync();
}

Future<void> main() async {
  Isolate.run(main2);
}
