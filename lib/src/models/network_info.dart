class NetworkInfo {
  final String? network;
  final bool isValid;
  final String? description;
  final Map<String, dynamic>? metadata;

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
