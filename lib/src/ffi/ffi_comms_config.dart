import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.g.dart';
import 'package:tari/src/utils/pointer_char_extension.dart';

/// Tari comms config wrapper.
class FFICommsConfig extends FFIBase<TariCommsConfig> {
  FFICommsConfig(
    String publicAddress,
    FFITariTransportConfig transport,
    String databaseName,
    String datastorePath,
    int discoveryTimeoutSec,
  ) {
    if (databaseName.isEmpty) throw Exception("databaseName may not be empty");

    final publicAddressPtr = publicAddress.toNativeUtf8().cast<Char>();
    final databaseNamePtr = databaseName.toNativeUtf8().cast<Char>();
    final datastorePathPtr = datastorePath.toNativeUtf8().cast<Char>();

    pointer = runWithError((errorPtr) => lib.comms_config_create(
          publicAddressPtr,
          transport.pointer,
          databaseNamePtr,
          datastorePathPtr,
          discoveryTimeoutSec,
          false,
          errorPtr,
        ));

    publicAddressPtr.free();
    databaseNamePtr.free();
    datastorePathPtr.free();
  }

  String getLastVersion() =>
      runWithError((errorPtr) => lib.wallet_get_last_version(pointer, errorPtr))
          .toDartString()!;

  @override
  void destroy() => lib.comms_config_destroy(pointer);
}
