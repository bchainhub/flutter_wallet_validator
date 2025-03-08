class ValidationOptions {
  final List<String>? network; // Default: null (no exclusion)
  final bool testnet; // Default: false
  final bool enabledLegacy; // Default: true
  final bool emojiAllowed; // Default: true
  final List<String> nsDomains; // Default: []

  const ValidationOptions({
    this.network,
    this.testnet = false,
    this.enabledLegacy = true,
    this.emojiAllowed = true,
    this.nsDomains = const [],
  });
}
