import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.g.dart';
import 'package:tari/src/utils/pointer_char_extension.dart';

enum TariLanguage { English, Spanish }

enum SeedWordsWordPushResult {
  InvalidSeedWord,
  SuccessfulPush,
  SeedPhraseComplete,
  InvalidSeedPhrase;

  static SeedWordsWordPushResult fromInt(int value) =>
      values.firstWhere((e) => e.index == value);
}

/// Wrapper for the native seed words type.
class FFISeedWords extends FFIIterableBase<String, TariSeedWords> {
  static FFISeedWords getMnemonicWordList(TariLanguage language) =>
      runWithError((errorPtr) {
        final languagePtr = language.name.toNativeUtf8().cast<Char>();
        final seedPtr = lib.seed_words_get_mnemonic_word_list_for_language(
            languagePtr, errorPtr);
        languagePtr.free();
        return FFISeedWords(seedPtr);
      });

  FFISeedWords.empty() {
    pointer = lib.seed_words_create();
  }

  FFISeedWords.fromBase58(String base58, String passphrase) {
    final base58Ptr = base58.toNativeUtf8().cast<Char>();
    final passphrasePtr = base58.toNativeUtf8().cast<Char>();
    pointer = runWithError((errorPtr) =>
        lib.seed_words_create_from_cipher(base58Ptr, passphrasePtr, errorPtr));
    base58Ptr.free();
    passphrasePtr.free();
  }

  FFISeedWords(Pointer<TariSeedWords> pointer) {
    this.pointer = pointer;
  }

  @override
  int getLength() =>
      runWithError((errorPtr) => lib.seed_words_get_length(pointer, errorPtr));

  @override
  String getAt(int index) => runWithError((errorPtr) =>
      lib.seed_words_get_at(pointer, index, errorPtr).toDartString()!);

  SeedWordsWordPushResult pushWord(String word) => runWithError((errorPtr) {
        final wordPtr = word.toNativeUtf8().cast<Char>();
        final result =
            lib.seed_words_push_word(pointer, wordPtr, nullptr, errorPtr);
        wordPtr.free();
        return SeedWordsWordPushResult.fromInt(result);
      });

  @override
  void destroy() => lib.seed_words_destroy(pointer);
}
