import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tari/ffi.dart';
import 'package:tari/src/generated_bindings_tari.freeze.g.dart';
import 'package:tari/src/utils/pointer_char_extension.dart';

class FFITariTransportConfig extends FFIBase<TariTransportConfig> {
  /// Default constructor creates memory transport.
  FFITariTransportConfig() {
    pointer = lib.transport_memory_create();
  }

  /// TCP transport.
  FFITariTransportConfig.tcp(String listenerAddress) {
    final listenerAddressPtr = listenerAddress.toNativeUtf8().cast<Char>();
    pointer = runWithError(
        (errorPtr) => lib.transport_tcp_create(listenerAddressPtr, errorPtr));
    listenerAddressPtr.free();
  }

  /// Tor transport.
  FFITariTransportConfig.tor(String controlAddress, FFIByteVector torCookie,
      int torPort, String socksUsername, String socksPassword) {
    final controlAddressPtr = controlAddress.toNativeUtf8().cast<Char>();
    final socksUsernamePtr = socksUsername.toNativeUtf8().cast<Char>();
    final socksPasswordPtr = socksPassword.toNativeUtf8().cast<Char>();

    pointer = runWithError(
      (errorPtr) => lib.transport_tor_create(
        controlAddressPtr,
        torCookie.pointer,
        torPort,
        false,
        socksUsernamePtr,
        socksPasswordPtr,
        errorPtr,
      ),
    );

    controlAddressPtr.free();
    socksUsernamePtr.free();
    socksPasswordPtr.free();
  }

  String getAddress() => runWithError((errorPtr) =>
      lib.transport_memory_get_address(pointer, errorPtr).toDartString()!);

  @override
  void destroy() => lib.transport_type_destroy(pointer);
}
