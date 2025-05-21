import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tari/src/exceptions.dart';
import 'package:tari/src/utils/pointer_char_extension.dart';

void throwIf(Pointer<Int> errorCode) {
  final value = errorCode.toInt();
  if (value != 0) throw getExceptionFromCode(value);
}

T runWithError<T>(T Function(Pointer<Int> error) fn) {
  final error = malloc<Int>();
  final result = fn(error);
  throwIf(error);
  return result;
}

class FFIException implements TariException {
  final int code;

  FFIException(this.code);

  @override
  String toString() => "FFIError Code: $code";
}
