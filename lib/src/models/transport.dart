abstract class Transport {
  String encode(String hex);
  String decode(String data);
  int count(String hex, [String? type]);
  Map<String, List<String>> getEndpoint([
    dynamic network,
    dynamic countriesList,
  ]);
  String sms({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });
  String mms({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });
  String generateMessageUri(
    String type, {
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });
  Future<String> downloadMessage(
    dynamic hex, {
    String? optionalFilename,
    String? optionalPath,
  });
  Future<bool> openSmsClient({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });
  Future<bool> openMmsClient({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });
}
