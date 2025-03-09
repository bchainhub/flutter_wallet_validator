# Flutter Wallet Validator

[![pub package](https://img.shields.io/pub/v/flutter_wallet_validator.svg)](https://pub.dev/packages/flutter_wallet_validator)
[![License: CORE](https://img.shields.io/badge/License-CORE-yellow.svg)](LICENSE)
[![Flutter Platform](https://img.shields.io/badge/Flutter-Platform-blue.svg)](https://flutter.dev)
[![Dart SDK Version](https://img.shields.io/badge/Dart-SDK%20%3E%3D%203.5.0-blue.svg)](https://dart.dev)

A comprehensive Flutter library for validating blockchain wallet addresses across multiple networks.

## Features

- 🚀 **Lightweight**: Minimal impact on app size
- 🔒 **Type-safe**: Written in Dart with full type definitions
- ⚡ **Fast**: No heavy dependencies
- 🧪 **Well-tested**: Production-ready test coverage
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
  flutter_wallet_validator: ^0.1.0
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

This package helps validate the format of blockchain addresses but does not guarantee the security or ownership of the addresses. Always verify addresses through multiple sources before sending any transactions.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Licensed under the [CORE License](LICENSE).
