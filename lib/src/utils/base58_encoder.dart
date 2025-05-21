import 'dart:typed_data';

String encodeBase58(Uint8List input) {
  const String alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  BigInt intData = BigInt.from(0);

  // Convert input byte array to BigInt
  for (var byte in input) {
    intData = (intData << 8) + BigInt.from(byte);
  }

  StringBuffer result = StringBuffer();
  while (intData > BigInt.zero) {
    int remainder = (intData % BigInt.from(58)).toInt();
    intData = intData ~/ BigInt.from(58);
    result.write(alphabet[remainder]);
  }

  // Add leading '1's for each leading zero byte
  for (var byte in input) {
    if (byte == 0) {
      result.write('1');
    } else {
      break;
    }
  }

  return result.toString().split('').reversed.join('');
}
