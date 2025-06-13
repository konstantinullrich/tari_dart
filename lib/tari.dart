import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.freeze.g.dart' as tari;
import 'package:tari/src/types.dart';
import 'package:tari/src/utils/base58_encoder.dart';
import 'package:tari/src/utils/pointer_char_extension.dart';
import 'package:tari/src/utils/uint64_to_bigint.dart';

export 'src/types.dart';

String tariNetwork = 'mainnet';

void _freeAll(List<Pointer> pointers) {
  for (final ptr in pointers) {
    // lib.free(ptr as Pointer<Void>);
  }
}

class TariBalanceInfo {
  final int available;
  final int pendingIncoming;
  final int pendingOutgoing;
  final int timeLocked;

  TariBalanceInfo(this.available, this.pendingIncoming, this.pendingOutgoing,
      this.timeLocked);
}

class TariAddressInfo {
  final String emojiId;
  final String base58;

  TariAddressInfo(this.emojiId, this.base58);
}

class TariWallet {
  Pointer<tari.TariWallet>? wallet;

  TariWallet(this.wallet);

  static List<String> getSeedWordList(
      [TariLanguage language = TariLanguage.English]) =>
      FFISeedWords.getMnemonicWordList(language).toListAndDestroy();

  TariBalanceInfo getBalance() {
    final balance = runWithError(
            (errorPtr) =>
            FFIBalance(lib.wallet_get_balance(wallet!, errorPtr)));

    final availableBalance = balance.getAvailable();
    final pendingIncoming = balance.getIncoming();
    final pendingOutgoing = balance.getOutgoing();
    final timeLockedBalance = balance.getTimeLocked();

    balance.destroy();

    return TariBalanceInfo(
        availableBalance, pendingIncoming, pendingOutgoing, timeLockedBalance);
  }

  TariAddressInfo getEmojiID([bool interactive = true]) {
    final address = interactive
        ? runWithError((errorPtr) =>
        FFITariWalletAddress(
            lib.wallet_get_tari_interactive_address(wallet!, errorPtr)))
        : runWithError((errorPtr) =>
        FFITariWalletAddress(
            lib.wallet_get_tari_one_sided_address(wallet!, errorPtr)));

    // Base58
    final network = Uint8List.fromList([address.getNetwork()]);
    final networkB58 = encodeBase58(network);

    final features = Uint8List.fromList([address.getFeatures()]);
    print(features);
    final featuresB58 = encodeBase58(features);

    final bytesVector = address.getByteVector();
    final bytesB58 = encodeBase58(bytesVector.asByteArray().sublist(2));
    bytesVector.destroy();

    return TariAddressInfo(address.getEmojiId() , [networkB58, featuresB58, bytesB58].join());
  }
  
  int estimateFee(int amount, int ? feePerGram) {
    final defaultKernelCount = 1;
    final defaultOutputCount = 2;
    final gram = feePerGram ?? 10;
    return runWithError((errorPtr) => lib.wallet_get_fee_estimate(wallet!, amount, nullptr, gram, defaultKernelCount, defaultOutputCount, errorPtr));
  }

  String sendTx(FFITariWalletAddress destination, BigInt amount,
      BigInt feePerGram, String message, bool isOneSided) {
    if (amount < BigInt.zero) {
      throw Exception("Amount is less than 0.");
    }

    // ToDo: avoid Self Send
    // if (destination == getWalletAddress()) {
    // throw Exception("Tx source and destination are the same.");
    // }

    final messagePtr = message.toNativeUtf8().cast<Char>();
    final txIdInt = runWithError((errorPtr) =>
        lib.wallet_send_transaction(
          wallet!,
          destination.pointer,
          amount.toInt(),
          nullptr, // commitments,
          feePerGram.toInt(),
          isOneSided,
          messagePtr,
          errorPtr,
        ));
    return uint64ToBigInt(txIdInt).toString();
  }

  List<FFICompletedTx> getCompletedTxs() =>
      runWithError((errorPtr) =>
          FFICompletedTxs(
              lib.wallet_get_completed_transactions(wallet!, errorPtr))
              .toListAndDestroy());

  List<FFICompletedTx> getCancelledTxs() =>
      runWithError((errorPtr) =>
          FFICompletedTxs(
              lib.wallet_get_cancelled_transactions(wallet!, errorPtr))
              .toListAndDestroy());

// fun getPendingOutboundTxs(): List<PendingOutboundTx> = runWithError {
// FFIPendingOutboundTxs(jniGetPendingOutboundTxs(it)).iterateWithDestroy { tx -> PendingOutboundTx(tx) }
// }
//
// fun getPendingInboundTxs(): List<PendingInboundTx> = runWithError {
// FFIPendingInboundTxs(jniGetPendingInboundTxs(it)).iterateWithDestroy { tx -> PendingInboundTx(tx) }
// }

  String signMessage(String message) {
    final messagePtr = message.toNativeUtf8().cast<Char>();

    final sig = runWithError((errorPtr) =>
    lib.wallet_sign_message(wallet!, messagePtr, errorPtr).toDartString()!);
    messagePtr.free();
    return sig;
  }

  String getMnemonic() {
    final seedWordsFfi = runWithError((errorPtr) =>
        FFISeedWords(lib.wallet_get_seed_words(wallet!, errorPtr)));
    final seedWords = <String>[];

    for (var i = 0; i < seedWordsFfi.getLength(); i++) {
      final word = seedWordsFfi.getAt(i);
      seedWords.add(word);
    }

    seedWordsFfi.destroy();

    return seedWords.join(" ");
  }

  bool startRecovery(CallbackRecoveryProgress recoveryCallback) {
    print('Starting wallet recovery process...');
    
    final recoveryProgress =
    NativeCallable<CallableRecoveryProgress>.listener(recoveryCallback);
    print('Recovery progress callback registered');

    try {
      

      final hasStarted = runWithError((errorPtr) {
        print('Attempting to start recovery with wallet pointer: ${wallet != null ? 'valid' : 'null'}');
        final result = lib.wallet_start_recovery(
            wallet!,
            nullptr,
            recoveryProgress.nativeFunction,
            nullptr, // Using nullptr instead of empty string to avoid double free
            errorPtr);
        
        if (errorPtr.value != 0) {
          print('Error during recovery start: ${errorPtr.value}');
        }
        return result;
      });

      print('Recovery process ${hasStarted ? 'started successfully' : 'failed to start'}');
      return hasStarted;
    } catch (e) {
      print('Exception during recovery process: $e');
      return false;
    }
  }

  bool isRecovering() =>
      runWithError(
              (errorPtr) {
                final result = lib.wallet_is_recovery_in_progress(wallet!, errorPtr);

                return result;
              });

  int getBaseNodeHeight() =>  0;

  bool setBaseNode() {
    final pkPointer = FFIPublicKey.fromHex('e46c810703da304aa4fb774ce3926bea224133f52d115915cc5a0341a393fb13');
    final address = '/ip4/192.168.0.205/tcp/9998'.toNativeUtf8().cast<Char>();
    final result = runWithError((errorPtr) => lib.wallet_set_base_node_peer(wallet!, pkPointer.pointer, address, errorPtr));

    pkPointer.destroy();
    lib.string_destroy(address);
    return result;
  }

  void close() {
    lib.wallet_destroy(wallet!);
    wallet = null;
  }
}

FFISeedWords getSeedWordsFromString(String mnemonic, [String separator = " "]) {
  final words = mnemonic.split(separator);
  final seedWords = FFISeedWords.empty();

  for (final word in words) {
    seedWords.pushWord(word);
  }

  return seedWords;
}

FFICommsConfig getWalletConfig({
  required String path,
  required FFITariTransportConfig transport,
  String walletDatabase = "wallet.dat",
  String publicAddress = "/ip4/0.0.0.0/tcp/9838",
}) =>
    FFICommsConfig(publicAddress, transport, walletDatabase, path, 300);

TariWallet createWallet({
  required FFICommsConfig commsConfig,
  String? mnemonic,
  required String passphrase,
  required String logPath,
  int logLevel = 3,
  required CallbackReceivedTransaction callbackReceivedTransaction,
  required CallbackReceivedTransactionReply callbackReceivedTransactionReply,
  required CallbackReceivedFinalizedTransaction
  callbackReceivedFinalizedTransaction,
  required CallbackReceivedTransactionBroadcast
  callbackReceivedTransactionBroadcast,
  required CallbackReceivedTransactionMined callbackReceivedTransactionMined,
  required CallbackReceivedTransactionMinedUnconfirmed
  callbackReceivedTransactionMinedUnconfirmed,
  required CallbackFauxTransactionMinedConfirmed
  callbackFauxTransactionMinedConfirmed,
  required CallbackFauxTransactionMinedUnconfirmed
  callbackFauxTransactionMinedUnconfirmed,
  required CallbackTransactionSendResult callbackTransactionSendResult,
  required CallbackTransactionCancellation callbackTransactionCancellation,
  required CallbackTxoValidationComplete callbackTxoValidationComplete,
  required CallbackContactsLivenessDataUpdated
  callbackContactsLivenessDataUpdated,
  required CallbackBalanceUpdated callbackBalanceUpdated,
  required CallbackTransactionValidationComplete
  callbackTransactionValidationComplete,
  required CallbackSafMessagesReceived callbackSafMessagesReceived,
  required CallbackConnectivityStatus callbackConnectivityStatus,
  required CallbackWalletScannedHeight callbackWalletScannedHeight,
  required CallbackBaseNodeState callbackBaseNodeState,
  String dnsSeeds = "",
  String dnsSeedNameServers = "",
  bool useDnsSec = false,
  String seedSeparator = " ",
}) {
  final logPathPtr = logPath.toNativeUtf8().cast<Char>();
  final passphrasePtr = passphrase.toNativeUtf8().cast<Char>();
  final seedPassphrasePtr = passphrase.toNativeUtf8().cast<Char>();
  final networkPtr = tariNetwork.toNativeUtf8().cast<Char>();
  final dnsSeedsPtr = dnsSeeds.toNativeUtf8().cast<Char>();
  final dnsSeedNameServersPtr = dnsSeedNameServers.isNotEmpty
      ? dnsSeedNameServers.toNativeUtf8().cast<Char>()
      : nullptr;

  final isRecoveryPointer = malloc<Bool>();

  final seedWords =
  mnemonic != null ? getSeedWordsFromString(mnemonic, seedSeparator) : null;
  final wallet = runWithError((errorPtr) =>
      lib.wallet_create(
        nullptr,
        commsConfig.pointer,
        logPathPtr,
        logLevel,
        10000,
        2000000,
        passphrasePtr,
        nullptr,
        seedWords?.pointer ?? nullptr,
        networkPtr,
        dnsSeedsPtr,
        dnsSeedNameServersPtr,
        useDnsSec,
        NativeCallable<CallableReceivedTransaction>.listener(
            callbackReceivedTransaction)
            .nativeFunction,
        NativeCallable<CallableReceivedTransactionReply>.listener(
            callbackReceivedTransactionReply)
            .nativeFunction,
        NativeCallable<CallableReceivedFinalizedTransaction>.listener(
            callbackReceivedFinalizedTransaction)
            .nativeFunction,
        NativeCallable<CallableReceivedTransactionBroadcast>.listener(
            callbackReceivedTransactionBroadcast)
            .nativeFunction,
        NativeCallable<CallableReceivedTransactionMined>.listener(
            callbackReceivedTransactionMined)
            .nativeFunction,
        NativeCallable<CallableReceivedTransactionMinedUnconfirmed>.listener(
            callbackReceivedTransactionMinedUnconfirmed)
            .nativeFunction,
        NativeCallable<CallableFauxTransactionMinedConfirmed>.listener(
            callbackFauxTransactionMinedConfirmed)
            .nativeFunction,
        NativeCallable<CallableFauxTransactionMinedUnconfirmed>.listener(
            callbackFauxTransactionMinedUnconfirmed)
            .nativeFunction,
        NativeCallable<CallableTransactionSendResult>.listener(
            callbackTransactionSendResult)
            .nativeFunction,
        NativeCallable<CallableTransactionCancellation>.listener(
            callbackTransactionCancellation)
            .nativeFunction,
        NativeCallable<CallableTxoValidationComplete>.listener(
            callbackTxoValidationComplete)
            .nativeFunction,
        NativeCallable<CallableContactsLivenessDataUpdated>.listener(
            callbackContactsLivenessDataUpdated)
            .nativeFunction,
        NativeCallable<CallableBalanceUpdated>.listener(callbackBalanceUpdated)
            .nativeFunction,
        NativeCallable<CallableTransactionValidationComplete>.listener(
            callbackTransactionValidationComplete)
            .nativeFunction,
        NativeCallable<CallableSafMessagesReceived>.listener(
            callbackSafMessagesReceived)
            .nativeFunction,
        NativeCallable<CallableConnectivityStatus>.listener(
            callbackConnectivityStatus)
            .nativeFunction,
        NativeCallable<CallableWalletScannedHeight>.listener(
            callbackWalletScannedHeight)
            .nativeFunction,
        NativeCallable<CallableBaseNodeState>.listener(callbackBaseNodeState)
            .nativeFunction,
        isRecoveryPointer,
        errorPtr,
      ));

  seedWords?.destroy();
  print('Wallet recovery pointer: ${isRecoveryPointer.value}');

  _freeAll([
    logPathPtr,
    passphrasePtr,
    seedPassphrasePtr,
    networkPtr,
    dnsSeedsPtr,
    dnsSeedNameServersPtr,
  ]);

  return TariWallet(wallet);
}
