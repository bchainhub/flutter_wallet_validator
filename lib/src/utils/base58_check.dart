import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class Base58Check {
  static const _alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  static final _alphabetBytes = _alphabet.codeUnits;
  static final _indexes = List.filled(128, -1);

  static void _initIndexes() {
    if (_indexes[_alphabetBytes[0]] != -1) return; // Already initialized

    for (var i = 0; i < _alphabet.length; i++) {
      _indexes[_alphabetBytes[i]] = i;
    }
  }

  static Uint8List decode(String input) {
    _initIndexes();

    if (input.isEmpty) {
      throw FormatException('Empty string');
    }

    // Convert input to bytes and count leading zeros
    var zeros = 0;
    while (zeros < input.length && input[zeros] == '1') {
      zeros++;
    }

    // Calculate result size
    final size = (input.length - zeros) * 733 ~/ 1000 + 1; // log(58) / log(256)
    final result = Uint8List(size);
    var length = 0;

    // Convert from Base58 to binary
    for (var i = zeros; i < input.length; i++) {
      final digit = input.codeUnitAt(i);
      if (digit >= 128 || _indexes[digit] == -1) {
        throw FormatException('Invalid Base58 character');
      }

      var carry = _indexes[digit];
      var j = 0;

      // Apply "b58 = b58 * 58 + digit"
      for (var k = size - 1; k >= 0; k--, j++) {
        if (carry == 0 && j >= length) break;
        carry += 58 * result[k];
        result[k] = carry & 0xff;
        carry >>= 8;
      }

      length = j;
    }

    // Skip leading zeros in result
    var startIndex = size - length;
    while (startIndex < size && result[startIndex] == 0) {
      startIndex++;
    }

    // Create final result with correct leading zeros
    final decoded = Uint8List(zeros + (size - startIndex));
    decoded.fillRange(0, zeros, 0);
    var j = zeros;
    for (var i = startIndex; i < size; i++) {
      decoded[j++] = result[i];
    }

    return decoded;
  }

  static String encode(Uint8List data) {
    if (data.isEmpty) {
      return '';
    }

    // Count leading zeros
    var zeros = 0;
    while (zeros < data.length && data[zeros] == 0) {
      zeros++;
    }

    // Calculate result size
    final size = (data.length - zeros) * 138 ~/ 100 + 1; // log(256) / log(58)
    final result = Uint8List(size);
    var length = 0;

    // Convert from binary to Base58
    for (var i = zeros; i < data.length; i++) {
      var carry = data[i];
      var j = 0;

      // Apply "b58 = b58 * 256 + ch"
      for (var k = size - 1; k >= 0; k--, j++) {
        if (carry == 0 && j >= length) break;
        carry += 256 * result[k];
        result[k] = carry % 58;
        carry ~/= 58;
      }

      length = j;
    }

    // Skip leading zeros in result
    var startIndex = size - length;
    while (startIndex < size && result[startIndex] == 0) {
      startIndex++;
    }

    // Create the final Base58 string
    final buffer = StringBuffer();
    buffer.write('1' * zeros);
    for (var i = startIndex; i < size; i++) {
      buffer.write(_alphabet[result[i]]);
    }

    return buffer.toString();
  }

  static bool validate(String address) {
    try {
      final decoded = decode(address);
      if (decoded.length < 4) return false;

      // Extract checksum and payload
      final checksum = decoded.sublist(decoded.length - 4);
      final payload = decoded.sublist(0, decoded.length - 4);

      // Calculate checksum
      final hash = sha256.convert(sha256.convert(payload).bytes).bytes;
      final calculatedChecksum = hash.sublist(0, 4);

      // Compare checksums
      for (var i = 0; i < 4; i++) {
        if (checksum[i] != calculatedChecksum[i]) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
