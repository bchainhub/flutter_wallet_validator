# Changelog

## 0.1.4

- Added checksum-aware Bech32 and Bech32m decoding.
- Added witness-version and witness-program validation for Bitcoin and
  Litecoin native SegWit addresses.
- Added checksum and payload validation for Bitcoin Cash, Cardano, Cosmos,
  Polkadot SS58, Algorand, Stellar, Ripple, and Tron addresses.
- Added exact decoded-key-length validation for Solana addresses.
- Restricted Bitcoin, Litecoin, and Tron Base58Check validation by network
  version and payload length.
- Fixed Tron addresses being classified as Solana and XRP addresses being
  rejected by the Solana validator.
- Fixed uppercase ICAN testnet addresses bypassing the testnet option.
- Added corrupted-checksum, testnet, and cross-network regression tests.
- Corrected the documented EVM network identifier to `evm`.
- Updated `convert` to 3.1.2 and `crypto` to 3.0.7.
- Updated the development lint rules to `flutter_lints` 6.0.0.
- Refreshed transitive dependencies for Flutter 3.44.9 and Dart 3.12.2.
- Updated issue forms and continuous-integration validation.
- Verified formatting, static analysis, tests, package publication, and a web
  consumer build.

## 0.1.3

- Updated pubspec.yaml
- Upgraded dependencies

## 0.1.2

- Changed the package description

## 0.1.1

- Better description
- Commented code

## 0.1.0

Initial release of the Flutter Wallet Validator package.

### Features

- ✨ Comprehensive blockchain address validation
- 🌐 Support for multiple networks:
  - Algorand
  - Bitcoin (Legacy, SegWit, Native SegWit)
  - Bitcoin Cash
  - Cardano (Mainnet, Testnet, Stake addresses)
  - Core (ICAN)
  - Cosmos ecosystem (Cosmos, Osmosis, Juno, etc.)
  - NS domains (ENS standard with subdomain and emoji support)
  - EVM-compatible chains (Ethereum, Polygon, BSC, etc.)
  - Litecoin (Legacy, SegWit, Native SegWit)
  - Polkadot
  - Ripple (XRP)
  - Solana
  - Stellar
  - Tron
- 🔒 Type-safe implementation with null safety
- ⚡ Efficient Base58Check validation
- 🧪 Comprehensive test coverage
- 📱 Support for all Flutter platforms including WASM

### Implementation Details

- Proper checksum validation for EVM addresses
- ICAN address format validation with checksum
- NS domain validation with length checks and emoji support
- Base58Check implementation for Bitcoin-like addresses
- Bech32 support for Native SegWit addresses
- Cross-network validation to prevent address conflicts

### Technical Requirements

- Dart SDK: >=3.5.0 <4.0.0
- Flutter: >=3.29.1
- Platforms: Android, iOS, Web, macOS, Windows, Linux, WASM
