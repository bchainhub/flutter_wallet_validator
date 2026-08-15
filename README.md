# Flutter Wallet Validator

[![pub package](https://img.shields.io/pub/v/flutter_wallet_validator.svg)](https://pub.dev/packages/flutter_wallet_validator)
[![License: CORE](https://img.shields.io/badge/License-CORE-yellow.svg)](LICENSE)
[![Flutter Platform](https://img.shields.io/badge/Flutter-Platform-blue.svg)](https://flutter.dev)
[![Dart SDK Version](https://img.shields.io/badge/Dart-SDK%20%3E%3D%203.5.0-blue.svg)](https://dart.dev)

A platform-independent Flutter library for validating blockchain wallet
addresses across multiple networks. It verifies network-specific checksums,
encoded payloads, address lengths, and supported network prefixes where the
address format provides them.

## Features

- 🚀 **Lightweight**: Minimal impact on app size
- 🔒 **Type-safe**: Written in Dart with full type definitions
- ⚡ **Fast**: No heavy dependencies
- 🧪 **Well-tested**: Positive, corrupted-checksum, testnet, and cross-network
  regression coverage
- 🌐 **Multi-network support**:
  - Algorand
  - Bitcoin (Legacy, SegWit, Native SegWit)
  - Bitcoin Cash
  - Cardano
  - Core (ICAN)
  - Cosmos ecosystem (Cosmos, Osmosis, Juno, etc.)
  - NS domains on ENS standard (including subdomains and emoji support)
  - EVM-compatible chains (Ethereum, Polygon, BSC, etc.)
  - Litecoin (Legacy, SegWit, Native SegWit)
  - Polkadot
  - Ripple (XRP)
  - Solana
  - Stellar
  - Tron
- 📦 **Modern package**:
  - Null safety
  - Platform independent
  - Zero configuration
  - Works on all Flutter platforms

## Installation

```yaml
dependencies:
  flutter_wallet_validator: ^0.1.4
```

Run:

```bash
flutter pub get
```

## Usage

### Basic Example

```dart
import 'package:flutter_wallet_validator/flutter_wallet_validator.dart';

void main() {
  // Validate an Ethereum address
  final result = validateWalletAddress(
    '0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97',
  );
  print(result);
  // NetworkInfo(
  //   network: 'evm',
  //   isValid: true,
  //   description: 'Ethereum Virtual Machine compatible address',
  //   metadata: {'isChecksumValid': true}
  // )
}
```

### With Options

```dart
// Validate with specific networks enabled
final result = validateWalletAddress(
  'vitalik.eth',
  options: ValidationOptions(
    network: ['ns'],
    nsDomains: ['eth'],
    testnet: false,
  ),
);
```

An empty `network` list, or a `null` list, enables all supported networks. A
non-empty list restricts detection to the supplied lowercase identifiers.

### Strict EVM checksum validation

EIP-55 permits applications to accept uniformly lowercase or uppercase
addresses without checking mixed-case capitalization. Set
`forceChecksumValidation` when your application requires every EVM address to
carry a valid EIP-55 checksum:

```dart
final result = validateWalletAddress(
  '0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97',
  forceChecksumValidation: true,
);
```

## Validation coverage

| Network | Identifier | Validation |
|---|---|---|
| Algorand | `algo` | Base32, decoded length, SHA-512/256 checksum |
| Bitcoin | `btc` | Base58Check version/payload or Bech32/Bech32m witness validation |
| Bitcoin Cash | `bch` | CashAddr prefix, payload size, and checksum |
| Cardano | `ada` | Bech32 checksum, HRP, network, address type, and payload length |
| Core ICAN | `ican`, `xcb`, `xce`, `xab` | ICAN format and MOD-97 checksum |
| Cosmos ecosystem | `atom` | Bech32 checksum, supported HRP, and payload length |
| EVM chains | `evm`, `eth`, `base`, `pol` | Hex format and EIP-55 checksum rules |
| Litecoin | `ltc` | Base58Check version/payload or Bech32/Bech32m witness validation |
| Polkadot | `dot` | SS58 decoding and Blake2b checksum |
| Ripple | `xrp` | XRP Base58 alphabet, version, payload, and checksum |
| Solana | `sol` | Base58 decoding to exactly 32 bytes |
| Stellar | `xlm` | StrKey version, payload length, and CRC16-XModem checksum |
| Tron | `trx`, `tron` | Base58Check version and payload length |
| Name-service domains | `ns` | Configured suffix and domain syntax only; no name resolution |

`network` reports the detected canonical identifier. Metadata can include the
encoded format, testnet status, checksum status, or chain prefix depending on
the network.

### Flutter Widget Example

```dart
class WalletAddressValidator extends StatelessWidget {
  final String address;

  const WalletAddressValidator({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final result = validateWalletAddress(address);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network: ${result.network ?? 'Unknown'}'),
            Text('Valid: ${result.isValid}'),
            Text('Description: ${result.description ?? 'N/A'}'),
            if (result.metadata != null)
              Text('Metadata: ${result.metadata}'),
          ],
        ),
      ),
    );
  }
}
```

## Platform Support

| Android | iOS | Web | macOS | Windows | Linux | WASM |
|---------|-----|-----|-------|---------|-------|------|
| ✅      | ✅  | ✅  | ✅    | ✅     | ✅    | ✅   |

## Environment

- 🎯 **Dart SDK**: >=3.5.0 <4.0.0
- 💙 **Flutter**: >=3.29.1
- 📱 **Platforms**: All Flutter supported platforms

## Security

This package validates the local structure and checksum of supported address
formats. It does not establish that an address exists, is active, belongs to a
particular person, or is safe to pay. Name-service validation checks syntax; it
does not resolve the name. Applications should still present the final
destination to the user before signing or broadcasting a transaction.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Licensed under the [CORE License](LICENSE).
