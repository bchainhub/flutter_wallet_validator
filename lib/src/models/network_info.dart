/// Information about a blockchain network and address validation results.
///
/// Contains details about:
/// - The identified network type
/// - Whether the address is valid for that network
/// - Optional description of the validation result
/// - Additional network-specific metadata
class NetworkInfo {
  /// The identified blockchain network (e.g., 'ETH', 'BTC', etc.)
  final String? network;

  /// Whether the address is valid for the identified network
  final bool isValid;

  /// Additional description or reason for the validation result
  final String? description;

  /// Network-specific metadata as key-value pairs
  final Map<String, dynamic>? metadata;

  /// Creates a new [NetworkInfo] instance.
  ///
  /// Parameters:
  /// - [network]: The identified blockchain network
  /// - [isValid]: Whether the address is valid
  /// - [description]: Optional description of the validation result
  /// - [metadata]: Optional network-specific metadata
  const NetworkInfo({
    this.network,
    required this.isValid,
    this.description,
    this.metadata,
  });

  @override
  String toString() {
    return 'NetworkInfo(network: $network, isValid: $isValid, description: $description, metadata: $metadata)';
  }
}
