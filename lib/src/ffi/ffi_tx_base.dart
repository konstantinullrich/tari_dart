import 'dart:ffi';

import 'package:tari/ffi.dart';

abstract class FFITxBase<T extends NativeType>  extends FFIBase<T> {
  FFITariWalletAddress getSourcePublicKey();
  FFITariWalletAddress getDestinationPublicKey();
  bool isOutbound();
}
