/// Abstract class defining the transport layer interface for message handling.
///
/// Provides methods for encoding/decoding messages, handling SMS/MMS,
/// and managing message endpoints across different platforms and networks.
abstract class Transport {
  /// Encodes a hexadecimal string into the transport format.
  String encode(String hex);

  /// Decodes transport data back into the original format.
  String decode(String data);

  /// Counts occurrences in a hexadecimal string, optionally filtered by type.
  ///
  /// Parameters:
  /// - [hex]: The hexadecimal string to analyze
  /// - [type]: Optional type filter
  int count(String hex, [String? type]);

  /// Retrieves endpoint information for the specified network and countries.
  ///
  /// Parameters:
  /// - [network]: Optional network specification
  /// - [countriesList]: Optional list of countries to filter endpoints
  Map<String, List<String>> getEndpoint([
    dynamic network,
    dynamic countriesList,
  ]);

  /// Generates an SMS message with the specified parameters.
  ///
  /// Parameters:
  /// - [number]: Target phone number
  /// - [message]: Message content
  /// - [network]: Optional network specification
  /// - [encodeMessage]: Whether to encode the message (default: true)
  /// - [platform]: Target platform (default: 'global')
  String sms({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });

  /// Generates an MMS message with the specified parameters.
  ///
  /// Parameters:
  /// - [number]: Target phone number
  /// - [message]: Message content
  /// - [network]: Optional network specification
  /// - [encodeMessage]: Whether to encode the message (default: true)
  /// - [platform]: Target platform (default: 'global')
  String mms({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });

  /// Generates a URI for a message of the specified type.
  ///
  /// Parameters:
  /// - [type]: Message type (e.g., 'sms', 'mms')
  /// - [number]: Target phone number
  /// - [message]: Message content
  /// - [network]: Optional network specification
  /// - [encodeMessage]: Whether to encode the message (default: true)
  /// - [platform]: Target platform (default: 'global')
  String generateMessageUri(
    String type, {
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });

  /// Downloads a message from its hexadecimal representation.
  ///
  /// Parameters:
  /// - [hex]: Hexadecimal representation of the message
  /// - [optionalFilename]: Optional filename for the downloaded content
  /// - [optionalPath]: Optional path for saving the downloaded content
  Future<String> downloadMessage(
    dynamic hex, {
    String? optionalFilename,
    String? optionalPath,
  });

  /// Opens the device's SMS client with pre-filled content.
  ///
  /// Parameters:
  /// - [number]: Target phone number
  /// - [message]: Message content
  /// - [network]: Optional network specification
  /// - [encodeMessage]: Whether to encode the message (default: true)
  /// - [platform]: Target platform (default: 'global')
  Future<bool> openSmsClient({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });

  /// Opens the device's MMS client with pre-filled content.
  ///
  /// Parameters:
  /// - [number]: Target phone number
  /// - [message]: Message content
  /// - [network]: Optional network specification
  /// - [encodeMessage]: Whether to encode the message (default: true)
  /// - [platform]: Target platform (default: 'global')
  Future<bool> openMmsClient({
    dynamic number,
    String? message,
    dynamic network,
    bool encodeMessage = true,
    String platform = 'global',
  });
}
