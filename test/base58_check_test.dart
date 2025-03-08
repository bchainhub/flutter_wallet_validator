import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_validator/src/utils/base58_check.dart';

void main() {
  group('Base58Check', () {
    test('validates correct Bitcoin addresses', () {
      final validAddresses = [
        '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
        '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
        '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs',
      ];

      for (final address in validAddresses) {
        expect(Base58Check.validate(address), isTrue);
      }
    });

    test('invalidates incorrect Bitcoin addresses', () {
      final invalidAddresses = [
        '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN3', // Changed last digit
        '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLx', // Changed last digit
        '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAt', // Changed last digit
        '', // Empty string
        '1', // Too short
        'invalid', // Invalid characters
      ];

      for (final address in invalidAddresses) {
        expect(Base58Check.validate(address), isFalse);
      }
    });

    test('encodes and decodes correctly', () {
      final testData = Uint8List.fromList([
        0x00,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x09,
        0x0A,
        0x0B,
        0x0C,
        0x0D,
        0x0E,
        0x0F,
      ]);

      final encoded = Base58Check.encode(testData);
      final decoded = Base58Check.decode(encoded);

      expect(decoded, equals(testData));
    });

    test('handles leading zeros', () {
      final testData = Uint8List.fromList([0x00, 0x00, 0x00, 0x01, 0x02, 0x03]);

      final encoded = Base58Check.encode(testData);
      final decoded = Base58Check.decode(encoded);

      expect(decoded, equals(testData));
      expect(encoded.startsWith('111'), isTrue);
    });
  });
}
