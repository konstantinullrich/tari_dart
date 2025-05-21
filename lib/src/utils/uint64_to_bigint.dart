BigInt uint64ToBigInt(int uint64Value) {
  if (uint64Value < 0) {
    return BigInt.from(uint64Value & 0x7FFFFFFFFFFFFFFF) + (BigInt.one << 63);
  } else {
    return BigInt.from(uint64Value);
  }
}
