import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_validator/flutter_wallet_validator.dart';

void main() {
  group('validateWalletAddress', () {
    group('EVM Addresses', () {
      test('validates checksum EVM address', () {
        final result = validateWalletAddress(
          '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
        );
        expect(result.network, equals('evm'));
        expect(result.isValid, isTrue);
        expect(result.description, contains('Ethereum Virtual Machine'));
        expect(result.metadata?['isChecksumValid'], isTrue);
      });

      test('validates lowercase EVM address', () {
        final result = validateWalletAddress(
          '0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed',
        );
        expect(result.network, equals('evm'));
        expect(result.isValid, isTrue);
        expect(result.metadata?['isChecksumValid'], isTrue);
      });

      test('invalidates incorrect checksum EVM address', () {
        final result = validateWalletAddress(
          '0x5AAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
        );
        expect(result.network, equals('evm'));
        expect(result.isValid, isFalse);
        expect(result.metadata?['isChecksumValid'], isFalse);
      });

      test('handles EVM addresses with valid hex but invalid length', () {
        final addresses = [
          '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAe', // one character short
          '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAedd', // one character long
        ];

        for (final address in addresses) {
          final result = validateWalletAddress(address);
          expect(result.network, equals('evm'));
          expect(result.isValid, isFalse);
        }
      });
    });

    group('NS Domains', () {
      test('validates simple NS domain', () {
        final result = validateWalletAddress(
          'vitalik.eth',
          options: const ValidationOptions(nsDomains: ['eth']),
        );
        expect(result.network, equals('ns'));
        expect(result.isValid, isTrue);
        expect(result.description, contains('Name Service domain'));
        expect(result.metadata?['isSubdomain'], isFalse);
      });

      test('validates NS domain with emojis', () {
        final validEmojiDomains = [
          '🦊.eth',
          'crypto🦊.eth',
          '🦊crypto.eth',
          'cry🦊pto.eth',
          '🦊🐻.eth',
          '🦊-crypto.eth',
        ];

        for (final domain in validEmojiDomains) {
          final result = validateWalletAddress(
            domain,
            options: const ValidationOptions(nsDomains: ['eth']),
          );
          expect(result.network, equals('ns'));
          expect(result.isValid, isTrue);
          expect(result.metadata?['format'], equals('eth'));
          expect(result.metadata?['isEmoji'], isTrue);
        }
      });

      test('validates NS subdomain with emojis', () {
        final validEmojiSubdomains = [
          '🦊.vitalik.eth',
          'wallet.🦊.eth',
          '🦊.🐻.eth',
        ];

        for (final domain in validEmojiSubdomains) {
          final result = validateWalletAddress(
            domain,
            options: const ValidationOptions(nsDomains: ['eth']),
          );
          expect(result.network, equals('ns'));
          expect(result.isValid, isTrue);
          expect(result.metadata?['format'], equals('eth'));
          expect(result.metadata?['isSubdomain'], isTrue);
          expect(result.metadata?['isEmoji'], isTrue);
        }
      });

      test('handles NS domains with maximum length components', () {
        final longLabel = 'a' * 63; // Maximum length for a DNS label
        final domains = ['$longLabel.eth', '$longLabel.$longLabel.eth'];

        for (final domain in domains) {
          final result = validateWalletAddress(
            domain,
            options: const ValidationOptions(nsDomains: ['eth']),
          );
          expect(result.network, equals('ns'));
          expect(result.isValid, isTrue);
        }
      });

      test('handles NS domains with invalid length components', () {
        final tooLongLabel =
            'a' * 256; // Exceeds maximum length for a DNS label
        final tooLongTotal = List.filled(
          5,
          'a' * 63,
        ).join('.'); // Creates a very long domain with dots

        final domains = [
          'sub.$tooLongLabel.eth', // Label too long in subdomain
          '$tooLongTotal.eth', // Total length too long (>255 chars)
        ];

        for (final domain in domains) {
          final result = validateWalletAddress(
            domain,
            options: const ValidationOptions(nsDomains: ['eth']),
          );
          expect(result.network, equals('ns'));
          expect(result.isValid, isFalse);
          expect(
            result.description,
            equals('NS domain exceeds maximum total length of 255 characters'),
          );
        }
      });
    });

    group('Bitcoin Addresses', () {
      test('validates Bitcoin Legacy address', () {
        final result = validateWalletAddress(
          '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
        );
        expect(result.network, equals('btc'));
        expect(result.isValid, isTrue);
        expect(result.description, contains('Bitcoin Legacy'));
        expect(result.metadata?['format'], equals('Legacy'));
      });

      test('validates Bitcoin SegWit address', () {
        final result = validateWalletAddress(
          '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
        );
        expect(result.network, equals('btc'));
        expect(result.isValid, isTrue);
        expect(result.description, contains('Bitcoin SegWit'));
      });

      test('validates Bitcoin Native SegWit address', () {
        final result = validateWalletAddress(
          'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq',
        );
        expect(result.network, equals('btc'));
        expect(result.isValid, isTrue);
        expect(result.description, contains('Bitcoin Native SegWit'));
      });
    });

    group('Cardano Addresses', () {
      test('validates mainnet payment address', () {
        final result = validateWalletAddress(
          'addr1qx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3n0d3vllmyqwsx5wktcd8cc3sq835lu7drv2xwl2wywfgse35a3x',
        );
        expect(result.network, equals('ada'));
        expect(result.isValid, isTrue);
        expect(result.metadata?['type'], equals('payment'));
        expect(result.metadata?['isTestnet'], isFalse);
      });

      test('validates stake address', () {
        final result = validateWalletAddress(
          'stake1uyehkck0lajq8gr28t9uxnuvgcqrc6070x3k9r8048z8y5gh6ffgw',
        );
        expect(result.network, equals('ada'));
        expect(result.isValid, isTrue);
        expect(result.metadata?['type'], equals('stake'));
        expect(result.metadata?['isTestnet'], isFalse);
      });
    });

    group('Cosmos Addresses', () {
      test('validates Cosmos addresses', () {
        final addresses = {
          'cosmos1yw6g44c4pqd2rxgrcqekxg9k8f4fd8xpx2k8c3': 'cosmos',
          'osmo1yw6g44c4pqd2rxgrcqekxg9k8f4fd8xpxqtvm3': 'osmo',
          'juno1yw6g44c4pqd2rxgrcqekxg9k8f4fd8xpxm4c8y': 'juno',
        };

        addresses.forEach((address, prefix) {
          final result = validateWalletAddress(address);
          expect(result.network, equals('atom'));
          expect(result.isValid, isTrue);
          expect(result.metadata?['chain'], equals(prefix));
        });
      });
    });

    group('Solana Addresses', () {
      test('validates Solana address', () {
        final result = validateWalletAddress(
          'DRpbCBMxVnDK7maPM5tGv6MvB3v1sRMC86PZ8okm21hy',
        );
        expect(result.network, equals('sol'));
        expect(result.isValid, isTrue);
      });
    });

    group('ICAN Addresses', () {
      test('validates mainnet ICAN address', () {
        final result = validateWalletAddress(
          'cb7147879011ea207df5b35a24ca6f0859dcfb145999',
        );
        expect(result.network, equals('xcb'));
        expect(result.isValid, isTrue);
        expect(result.metadata?['isTestnet'], isFalse);
      });

      test('validates testnet ICAN address', () {
        final result = validateWalletAddress(
          'ab7147879011ea207df5b35a24ca6f0859dcfb145999',
          options: const ValidationOptions(testnet: true),
        );
        expect(result.network, equals('xab'));
        expect(result.isValid, isTrue);
        expect(result.metadata?['isTestnet'], isTrue);
      });
    });

    group('Edge Cases and Corner Cases', () {
      test('handles addresses with mixed case prefixes', () {
        final addresses = [
          'BiTcOiNcAsH:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a',
          'Bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq',
          'TlTc1qk2ergl0hvg8g8r89nwqjl6m6k76rgwsh95qm9d',
        ];

        for (final address in addresses) {
          final result = validateWalletAddress(address);
          expect(result.isValid, isFalse);
          expect(
            result.description,
            anyOf(['Invalid address format', 'Unknown address format']),
          );
        }
      });

      test(
        'handles addresses with zero-width spaces and other invisible characters',
        () {
          final addresses = [
            '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed\u200B',
            '\u200E0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
            '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed\uFEFF',
          ];

          for (final address in addresses) {
            final result = validateWalletAddress(address);
            expect(result.isValid, isFalse);
            expect(
              result.description,
              anyOf(['Invalid address format', 'Unknown address format']),
            );
          }
        },
      );
    });

    group('Option Validation', () {
      test('handles invalid option types', () {
        final address = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';
        final invalidOptions = [
          const ValidationOptions(testnet: false, nsDomains: []),
          const ValidationOptions(network: ['sol']),
        ];

        for (final options in invalidOptions) {
          final result = validateWalletAddress(address, options: options);
          expect(result.isValid, isFalse);
          expect(result.description, contains('Invalid options'));
        }
      });
    });

    group('Cross-Network Validation', () {
      test('handles addresses that could be valid in multiple networks', () {
        final address = '1234567890123456789012345678901234567890';
        final networks = ['evm', 'btc', 'ltc', 'sol'];

        for (final network in networks) {
          final result = validateWalletAddress(
            address,
            options: ValidationOptions(network: [network]),
          );
          expect(result.isValid, isFalse);
        }
      });
    });

    group('Network Filtering', () {
      test('respects network filtering', () {
        final address = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';

        // Should validate when network is allowed
        final resultAllowed = validateWalletAddress(
          address,
          options: const ValidationOptions(network: ['evm']),
        );
        expect(resultAllowed.isValid, isTrue);
        expect(resultAllowed.network, equals('evm'));

        // Should not validate when network is not in allowed list
        final resultNotAllowed = validateWalletAddress(
          address,
          options: const ValidationOptions(network: ['btc', 'sol']),
        );
        expect(resultNotAllowed.isValid, isFalse);
      });
    });

    group('Testnet Handling', () {
      test('handles testnet addresses correctly', () {
        final testnetAddresses = [
          'tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx', // Bitcoin testnet
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3n0d3vllmyqwsx5wktcd8cc3sq835lu7drv2xwl2wywfgs9yc0hh', // Cardano testnet
        ];

        // Should fail without testnet option
        for (final address in testnetAddresses) {
          final result = validateWalletAddress(address);
          expect(result.isValid, isFalse);
        }

        // Should pass with testnet option
        for (final address in testnetAddresses) {
          final result = validateWalletAddress(
            address,
            options: const ValidationOptions(testnet: true),
          );
          expect(result.isValid, isTrue);
        }
      });
    });
  });
}
