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
