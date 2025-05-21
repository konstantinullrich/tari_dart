import 'dart:ffi';
import 'dart:io';

import 'package:tari/src/generated_bindings_tari.g.dart' as tari;

export 'src/ffi/ffi_balance.dart';
export 'src/ffi/ffi_base.dart';
export 'src/ffi/ffi_bytevector.dart';
export 'src/ffi/ffi_comms_config.dart';
export 'src/ffi/ffi_completed_tx.dart';
export 'src/ffi/ffi_completed_tx_kernel.dart';
export 'src/ffi/ffi_completed_txs.dart';
export 'src/ffi/ffi_exception.dart';
export 'src/ffi/ffi_public_key.dart';
export 'src/ffi/ffi_public_keys.dart';
export 'src/ffi/ffi_seed_words.dart';
export 'src/ffi/ffi_tari_transport_config.dart';
export 'src/ffi/ffi_tari_wallet_address.dart';
export 'src/ffi/ffi_tx_base.dart';

String libPath = (() {
  // if (Platform.isWindows) return 'monero_libwallet2_api_c.dll';
  if (Platform.isMacOS) return 'libminotari_wallet_ffi.dylib';
  if (Platform.isIOS) return 'TariWallet.framework/TariWallet';
  if (Platform.isAndroid) return 'libminotari_wallet_ffi.a';
  return 'libminotari_wallet_ffi.a';
})();

tari.Tari get lib => _tari ??= tari.Tari(DynamicLibrary.open(libPath));
tari.Tari? _tari;
