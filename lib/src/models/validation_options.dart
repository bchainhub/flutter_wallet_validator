/// Configuration options for wallet address validation.
///
/// Controls various aspects of the validation process including:
/// - Network filtering
/// - Testnet address validation
/// - Legacy address support
/// - Emoji support in addresses
/// - Name service domain validation
class ValidationOptions {
  /// List of specific networks to validate against.
  /// If null, all networks are considered.
  final List<String>? network;

  /// Whether to allow testnet addresses.
  /// Defaults to false.
  final bool testnet;

  /// Whether to allow legacy address formats.
  /// Defaults to true.
  final bool enabledLegacy;

  /// Whether to allow emoji characters in addresses.
  /// Defaults to true.
  final bool emojiAllowed;

  /// List of supported name service domains for resolution.
  /// Defaults to an empty list.
  final List<String> nsDomains;

  /// Creates a new [ValidationOptions] instance.
  ///
  /// All parameters are optional and have default values:
  /// - [network]: null (no network filtering)
  /// - [testnet]: false
  /// - [enabledLegacy]: true
  /// - [emojiAllowed]: true
  /// - [nsDomains]: empty list
  const ValidationOptions({
    this.network,
    this.testnet = false,
    this.enabledLegacy = true,
    this.emojiAllowed = true,
    this.nsDomains = const [],
  });
}
