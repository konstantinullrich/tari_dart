import 'package:tari/ffi.dart';

TariException getExceptionFromCode(int code) {
  switch (code) {
    case TariNullError.code:
      return TariNullError();
    case TariAllocationError.code:
      return TariAllocationError();
    case TariPositionInvalidError.code:
      return TariPositionInvalidError();
    case TariTokioError.code:
      return TariTokioError();
    case TariInvalidEmojiId.code:
      return TariInvalidEmojiId();
    case TariInvalidArgument.code:
      return TariInvalidArgument();
    case TariBalanceError.code:
      return TariBalanceError();
    case TariPointerError.code:
      return TariPointerError();
    case TariInternalError.code:
      return TariInternalError();
    default:
      return FFIException(code);
  }
}

abstract class TariException implements Exception {}

abstract class TariInterfaceError implements TariException {}

class TariNullError extends TariInterfaceError {
  static const int code = 1;
}

class TariAllocationError extends TariInterfaceError {
  static const int code = 2;
}

class TariPositionInvalidError extends TariInterfaceError {
  static const int code = 3;
}

class TariTokioError extends TariInterfaceError {
  static const int code = 4;
}

class TariInvalidEmojiId extends TariInterfaceError {
  static const int code = 6;
}

class TariInvalidArgument extends TariInterfaceError {
  static const int code = 7;
}

class TariBalanceError extends TariInterfaceError {
  static const int code = 8;
}

class TariPointerError extends TariInterfaceError {
  static const int code = 9;
}

class TariInternalError extends TariInterfaceError {
  static const int code = 10;
}
