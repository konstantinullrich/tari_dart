import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.g.dart';
import 'package:tari/src/utils/pointer_char_extension.dart';

/// Wrapper for native private key type.
class FFITariWalletAddress extends FFIBase<TariWalletAddress> {
  FFITariWalletAddress(Pointer<TariWalletAddress> pointer) {
    this.pointer = pointer;
  }

  FFITariWalletAddress.fromBytes(FFIByteVector bytes) {
    pointer = runWithError(
        (errorPtr) => lib.tari_address_create(bytes.pointer, errorPtr));
  }

  FFITariWalletAddress.fromBase58(String base58) {
    final base58Ptr = base58.toNativeUtf8().cast<Char>();
    pointer = runWithError(
        (errorPtr) => lib.tari_address_from_base58(base58Ptr, errorPtr));
    base58Ptr.free();
  }

  FFITariWalletAddress.fromEmojiId(String emojiId) {
    final emojiIdPtr = emojiId.toNativeUtf8().cast<Char>();
    pointer = runWithError(
        (errorPtr) => lib.emoji_id_to_tari_address(emojiIdPtr, errorPtr));
    emojiIdPtr.free();
  }

  FFIByteVector getByteVector() => runWithError((errorPtr) =>
      FFIByteVector(lib.tari_address_get_bytes(pointer, errorPtr)));

  String getEmojiId() => runWithError((errorPtr) =>
      lib.tari_address_to_emoji_id(pointer, errorPtr).toDartString()!);

  int getNetwork() => runWithError(
      (errorPtr) => lib.tari_address_network_u8(pointer, errorPtr));

  int getFeatures() => runWithError(
      (errorPtr) => lib.tari_address_features_u8(pointer, errorPtr));

  FFIPublicKey? getViewKey() => runWithError((errorPtr) {
        final viewKeyPtr = lib.tari_address_view_key(pointer, errorPtr);
        if (viewKeyPtr != nullptr) return FFIPublicKey(viewKeyPtr);
        return null;
      });

  FFIPublicKey getSpendKey() => runWithError((errorPtr) =>
      FFIPublicKey(lib.tari_address_spend_key(pointer, errorPtr)));

  int getChecksum() => runWithError(
      (errorPtr) => lib.tari_address_checksum_u8(pointer, errorPtr));

  String notificationHex() => getSpendKey().getByteVector().toHex();

  @override
  String toString() => getEmojiId();

  @override
  void destroy() => lib.tari_address_destroy(pointer);
}
