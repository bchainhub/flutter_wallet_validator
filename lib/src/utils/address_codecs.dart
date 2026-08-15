import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/digests/blake2b.dart';
import 'package:pointycastle/digests/sha512t.dart';

import 'base58_check.dart';

const _bech32Alphabet = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
const _rippleAlphabet =
    'rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz';

class Bech32Data {
  const Bech32Data(this.hrp, this.data, this.encodingConstant);

  final String hrp;
  final List<int> data;
  final int encodingConstant;
}

Bech32Data? decodeBech32(String value) {
  // Cardano deliberately permits Bech32 strings beyond BIP-173's original
  // 90-character presentation limit.
  if (value.length < 8 || value.length > 200) return null;
  if (value.toLowerCase() != value && value.toUpperCase() != value) return null;
  final normalized = value.toLowerCase();
  final separator = normalized.lastIndexOf('1');
  if (separator < 1 || separator + 7 > normalized.length) return null;
  final hrp = normalized.substring(0, separator);
  final data = <int>[];
  for (final rune in normalized.substring(separator + 1).runes) {
    final index = _bech32Alphabet.indexOf(String.fromCharCode(rune));
    if (index < 0) return null;
    data.add(index);
  }
  final polymod = _bech32Polymod([..._expandHrp(hrp), ...data]);
  if (polymod != 1 && polymod != 0x2bc830a3) return null;
  return Bech32Data(hrp, data.sublist(0, data.length - 6), polymod);
}

bool validateSegwitAddress(String value, Set<String> allowedHrps) {
  final decoded = decodeBech32(value);
  if (decoded == null ||
      !allowedHrps.contains(decoded.hrp) ||
      decoded.data.isEmpty) {
    return false;
  }
  final version = decoded.data.first;
  if (version > 16) return false;
  if ((version == 0 && decoded.encodingConstant != 1) ||
      (version != 0 && decoded.encodingConstant != 0x2bc830a3)) {
    return false;
  }
  final program = convertBits(decoded.data.sublist(1), 5, 8, pad: false);
  if (program == null || program.length < 2 || program.length > 40)
    return false;
  return version != 0 || program.length == 20 || program.length == 32;
}

List<int>? convertBits(List<int> data, int from, int to, {required bool pad}) {
  var accumulator = 0;
  var bits = 0;
  final output = <int>[];
  final maxValue = (1 << to) - 1;
  for (final value in data) {
    if (value < 0 || value >> from != 0) return null;
    accumulator = (accumulator << from) | value;
    bits += from;
    while (bits >= to) {
      bits -= to;
      output.add((accumulator >> bits) & maxValue);
    }
  }
  if (pad) {
    if (bits > 0) output.add((accumulator << (to - bits)) & maxValue);
  } else if (bits >= from || ((accumulator << (to - bits)) & maxValue) != 0) {
    return null;
  }
  return output;
}

bool validateBech32(
  String value,
  Set<String> allowedHrps, {
  Set<int>? payloadLengths,
}) {
  final decoded = decodeBech32(value);
  if (decoded == null ||
      decoded.encodingConstant != 1 ||
      !allowedHrps.contains(decoded.hrp) ||
      decoded.data.isEmpty) {
    return false;
  }
  final payload = convertBits(decoded.data, 5, 8, pad: false);
  return payload != null &&
      (payloadLengths == null || payloadLengths.contains(payload.length));
}

bool validateCardanoAddress(String value, {required bool testnet}) {
  final decoded = decodeBech32(value);
  if (decoded == null || decoded.encodingConstant != 1) return false;
  final isStake = value.startsWith(testnet ? 'stake_test1' : 'stake1');
  final expectedHrp = isStake
      ? (testnet ? 'stake_test' : 'stake')
      : (testnet ? 'addr_test' : 'addr');
  if (decoded.hrp != expectedHrp) return false;
  final payload = convertBits(decoded.data, 5, 8, pad: false);
  if (payload == null || payload.isEmpty) return false;
  final type = payload.first >> 4;
  final network = payload.first & 0x0f;
  if ((testnet && network == 1) || (!testnet && network != 1)) return false;
  if (isStake) return (type == 14 || type == 15) && payload.length == 29;
  return type <= 7 && payload.length >= 29 && payload.length <= 65;
}

bool validateCashAddr(String value) {
  final normalized = value.toLowerCase();
  if (value != normalized && value != value.toUpperCase()) return false;
  final separator = normalized.indexOf(':');
  final prefix =
      separator < 0 ? 'bitcoincash' : normalized.substring(0, separator);
  final payload =
      separator < 0 ? normalized : normalized.substring(separator + 1);
  if (prefix != 'bitcoincash' || payload.length < 8) return false;
  final values = <int>[];
  for (final rune in payload.runes) {
    final digit = _bech32Alphabet.indexOf(String.fromCharCode(rune));
    if (digit < 0) return false;
    values.add(digit);
  }
  final expandedPrefix = [
    ...prefix.codeUnits.map((character) => character & 31),
    0
  ];
  if (_cashAddrPolymod([...expandedPrefix, ...values]) != 0) return false;
  final decoded =
      convertBits(values.sublist(0, values.length - 8), 5, 8, pad: false);
  if (decoded == null || decoded.isEmpty) return false;
  final sizeCode = decoded.first & 7;
  const sizes = [20, 24, 28, 32, 40, 48, 56, 64];
  return decoded.length - 1 == sizes[sizeCode];
}

bool validateSolana(String value) {
  try {
    return Base58Check.decode(value).length == 32;
  } on FormatException {
    return false;
  }
}

bool validateBase58CheckNetwork(
  String value, {
  required Set<int> versions,
  required int payloadLength,
}) {
  if (!Base58Check.validate(value)) return false;
  final decoded = Base58Check.decode(value);
  return decoded.length == payloadLength + 5 &&
      versions.contains(decoded.first);
}

bool validateTron(String value) => validateBase58CheckNetwork(
      value,
      versions: const {0x41},
      payloadLength: 20,
    );

bool validateAlgorand(String value) {
  final decoded = decodeBase32(value);
  if (decoded == null || decoded.length != 36) return false;
  final publicKey = Uint8List.fromList(decoded.sublist(0, 32));
  final checksum = decoded.sublist(32);
  final digest = SHA512tDigest(256).process(publicKey);
  return _constantEquals(checksum, digest.sublist(digest.length - 4));
}

bool validateStellarAccount(String value) {
  final decoded = decodeBase32(value);
  if (decoded == null || decoded.length != 35 || decoded.first != 6 << 3) {
    return false;
  }
  final expected = decoded[33] | (decoded[34] << 8);
  return crc16Xmodem(decoded.sublist(0, 33)) == expected;
}

bool validateSs58(String value) {
  try {
    final decoded = Base58Check.decode(value);
    if (decoded.length < 3) return false;
    final prefixLength = decoded.first & 0x40 == 0 ? 1 : 2;
    if (decoded.length <= prefixLength + 1) return false;
    final checksumLength = decoded.length - prefixLength - 32;
    if (checksumLength < 1 || checksumLength > 8) return false;
    final payload = decoded.sublist(0, decoded.length - checksumLength);
    final input = Uint8List.fromList([...utf8.encode('SS58PRE'), ...payload]);
    final digest = Blake2bDigest(digestSize: 64).process(input);
    return _constantEquals(
        decoded.sublist(payload.length), digest.sublist(0, checksumLength));
  } on FormatException {
    return false;
  }
}

bool validateRipple(String value) {
  final decoded = decodeBase58(value, alphabet: _rippleAlphabet);
  if (decoded == null || decoded.length != 25 || decoded.first != 0)
    return false;
  final payload = decoded.sublist(0, 21);
  final checksum =
      sha256.convert(sha256.convert(payload).bytes).bytes.sublist(0, 4);
  return _constantEquals(decoded.sublist(21), checksum);
}

Uint8List? decodeBase32(String value) {
  var accumulator = 0;
  var bits = 0;
  final output = <int>[];
  for (final rune in value.toUpperCase().replaceAll('=', '').runes) {
    final digit = _base32Alphabet.indexOf(String.fromCharCode(rune));
    if (digit < 0) return null;
    accumulator = (accumulator << 5) | digit;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      output.add((accumulator >> bits) & 0xff);
    }
  }
  if (bits > 0 && (accumulator & ((1 << bits) - 1)) != 0) return null;
  return Uint8List.fromList(output);
}

Uint8List? decodeBase58(String value, {required String alphabet}) {
  if (value.isEmpty || alphabet.length != 58) return null;
  var number = BigInt.zero;
  for (final rune in value.runes) {
    final digit = alphabet.indexOf(String.fromCharCode(rune));
    if (digit < 0) return null;
    number = number * BigInt.from(58) + BigInt.from(digit);
  }
  final bytes = <int>[];
  while (number > BigInt.zero) {
    bytes.add((number & BigInt.from(0xff)).toInt());
    number >>= 8;
  }
  for (var i = 0; i < value.length && value[i] == alphabet[0]; i++) {
    bytes.add(0);
  }
  return Uint8List.fromList(bytes.reversed.toList());
}

int crc16Xmodem(List<int> bytes) {
  var crc = 0;
  for (final byte in bytes) {
    crc ^= byte << 8;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1;
      crc &= 0xffff;
    }
  }
  return crc;
}

List<int> _expandHrp(String hrp) => [
      ...hrp.codeUnits.map((character) => character >> 5),
      0,
      ...hrp.codeUnits.map((character) => character & 31),
    ];

int _bech32Polymod(List<int> values) {
  const generators = [
    0x3b6a57b2,
    0x26508e6d,
    0x1ea119fa,
    0x3d4233dd,
    0x2a1462b3
  ];
  var checksum = 1;
  for (final value in values) {
    final top = checksum >> 25;
    checksum = ((checksum & 0x1ffffff) << 5) ^ value;
    for (var bit = 0; bit < 5; bit++) {
      if ((top >> bit) & 1 != 0) checksum ^= generators[bit];
    }
  }
  return checksum;
}

int _cashAddrPolymod(List<int> values) {
  const generators = [
    0x98f2bc8e61,
    0x79b76d99e2,
    0xf33e5fb3c4,
    0xae2eabe2a8,
    0x1e4f43e470,
  ];
  var checksum = 1;
  for (final value in values) {
    final top = checksum >> 35;
    checksum = ((checksum & 0x07ffffffff) << 5) ^ value;
    for (var bit = 0; bit < 5; bit++) {
      if ((top >> bit) & 1 != 0) checksum ^= generators[bit];
    }
  }
  return checksum ^ 1;
}

bool _constantEquals(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  var difference = 0;
  for (var i = 0; i < left.length; i++) {
    difference |= left[i] ^ right[i];
  }
  return difference == 0;
}
