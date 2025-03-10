/// A library for validating cryptocurrency wallet addresses.
///
/// Provides functionality to validate addresses across multiple blockchain networks
/// including Bitcoin, Ethereum, and other major cryptocurrencies.
///
/// Example:
/// ```dart
/// final result = validateWalletAddress('0x742d35Cc6634C0532925a3b844Bc454e4438f44e');
/// print(result.isValid); // true
/// print(result.network); // 'ETH'
/// ```
library flutter_wallet_validator;

export 'src/validator.dart';
export 'src/models/network_info.dart';
export 'src/models/validation_options.dart';
