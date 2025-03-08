import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'models/network_info.dart';
import 'models/validation_options.dart';
import 'utils/patterns.dart';
import 'utils/base58_check.dart';

/// Validates a blockchain wallet address and returns information about the network it belongs to
NetworkInfo validateWalletAddress(
  String? address, {
  ValidationOptions options = const ValidationOptions(),
  bool forceChecksumValidation = false,
}) {
  // Validate options first
  final optionsError = _validateOptions(options);
  if (optionsError != null) return optionsError;

  // Handle empty or invalid input
  if (address == null || address.isEmpty) {
    return const NetworkInfo(
      network: null,
      isValid: false,
      description: 'Invalid input',
    );
  }

  final allowedNetworks = options.network ?? [];

  // NS Domain validation (check before other validations)
  if (options.nsDomains.isNotEmpty) {
    final addressForMatching =
        address.trim().replaceAll(RegExp(r'\.+$'), '').toLowerCase();
    final matchedDomain = options.nsDomains.firstWhere(
      (domain) => addressForMatching.endsWith('.$domain'.toLowerCase()),
      orElse: () => '',
    );

    if (matchedDomain.isNotEmpty) {
      final baseResponse = const NetworkInfo(
        network: 'ns',
        isValid: false,
        description: 'Invalid NS domain format',
      );

      // Check total length (max 255 characters including dots)
      if (addressForMatching.length > 255) {
        return const NetworkInfo(
          network: 'ns',
          isValid: false,
          description:
              'NS domain exceeds maximum total length of 255 characters',
        );
      }

      // Check individual label lengths (max 63 characters)
      final labels = addressForMatching.split('.');
      for (final label in labels) {
        if (label.length > 63) {
          return const NetworkInfo(
            network: 'ns',
            isValid: false,
            description:
                'NS domain label exceeds maximum length of 63 characters',
          );
        }
      }

      // Check for basic format issues
      if (address != address.trim() || // has leading/trailing spaces
          address.contains('..') || // has consecutive dots
          RegExp(r'\s').hasMatch(address) || // has spaces anywhere
          address.startsWith('.') || // starts with dot
          address.endsWith('.')) {
        // ends with dot
        return baseResponse;
      }

      // Check for invalid characters (but allow emojis)
      final validPattern = RegExp(
        r'^[a-zA-Z0-9-\p{Emoji_Presentation}\p{Extended_Pictographic}]+(?:\.[a-zA-Z0-9-\p{Emoji_Presentation}\p{Extended_Pictographic}]+)*\.[a-zA-Z]+$',
        unicode: true,
      );
      if (!validPattern.hasMatch(address)) {
        return baseResponse;
      }

      // Check emoji allowance
      final containsEmojis = RegExp(
        r'\p{Extended_Pictographic}',
        unicode: true,
      ).hasMatch(address);
      if (containsEmojis && !options.emojiAllowed) {
        return const NetworkInfo(
          network: 'ns',
          isValid: false,
          description: 'Emoji characters are disabled in NS domains',
        );
      }

      // If we get here, the domain is valid
      final isSubdomain = address.split('.').length > 2;

      return NetworkInfo(
        network: 'ns',
        isValid: true,
        description: 'Name Service domain',
        metadata: {
          'format': matchedDomain,
          'isSubdomain': isSubdomain,
          'isEmoji': containsEmojis,
        },
      );
    }
  }

  // Handle EVM-like addresses first
  if (address.toLowerCase().startsWith('0x') &&
      _enabledNetwork(['evm', 'eth', 'base', 'pol'], allowedNetworks)) {
    if (!Patterns.evm.hasMatch(address)) {
      return const NetworkInfo(
        network: 'evm',
        isValid: false,
        description: 'Invalid EVM address format',
      );
    }

    final isChecksumValid = _validateEVMChecksum(
      address,
      forceChecksumValidation,
    );

    return NetworkInfo(
      network: 'evm',
      isValid: isChecksumValid,
      description:
          'Ethereum Virtual Machine compatible address (Ethereum, Polygon, BSC, etc.)',
      metadata: {'format': 'hex', 'isChecksumValid': isChecksumValid},
    );
  }

  // Core (ICAN)
  if (_enabledNetwork(['ican', 'xcb', 'xce', 'xab'], allowedNetworks) &&
      Patterns.ican.hasMatch(address)) {
    final isTestnet = address.startsWith('ab');
    if (isTestnet && !options.testnet) {
      return const NetworkInfo(
        network: 'xab',
        isValid: false,
        description: 'Testnet address not allowed',
      );
    }
    final isChecksumValid = _validateICANChecksum(address);
    final prefix = address.substring(0, 2).toLowerCase();
    return NetworkInfo(
      network: 'x$prefix',
      isValid: isChecksumValid,
      description: 'ICAN address for Core blockchain networks',
      metadata: {
        'format': 'ican',
        'isChecksumValid': isChecksumValid,
        'codename': prefix == 'cb'
            ? 'Mainnet'
            : prefix == 'ce'
                ? 'Koliba'
                : prefix == 'ab'
                    ? 'Devin'
                    : null,
        'isTestnet': isTestnet,
        'printFormat': _formatICANAddress(address),
        'electronicFormat': address.toUpperCase(),
      },
    );
  }

  // Bitcoin addresses
  if (_enabledNetwork(['btc'], allowedNetworks)) {
    // Bitcoin Legacy
    if (options.enabledLegacy && Patterns.btcLegacy.hasMatch(address)) {
      try {
        _validateBase58Check(address);
        return const NetworkInfo(
          network: 'btc',
          isValid: true,
          description: 'Bitcoin Legacy address',
          metadata: {
            'format': 'Legacy',
            'isTestnet': false,
            'compatibleWith': ['bch'],
          },
        );
      } catch (_) {
        return const NetworkInfo(
          network: 'btc',
          isValid: false,
          description: 'Invalid Bitcoin Legacy address',
        );
      }
    }

    // Bitcoin SegWit
    if (Patterns.btcSegwit.hasMatch(address)) {
      try {
        _validateBase58Check(address);
        return const NetworkInfo(
          network: 'btc',
          isValid: true,
          description: 'Bitcoin SegWit address',
          metadata: {'format': 'SegWit', 'isTestnet': false},
        );
      } catch (_) {
        return const NetworkInfo(
          network: 'btc',
          isValid: false,
          description: 'Invalid Bitcoin SegWit address',
        );
      }
    }

    // Bitcoin Native SegWit
    if (Patterns.btcNativeSegwit.hasMatch(address)) {
      final isTestnet = address.startsWith('tb1');
      if (isTestnet && !options.testnet) {
        return const NetworkInfo(
          network: 'btc',
          isValid: false,
          description: 'Testnet address not allowed',
        );
      }
      return NetworkInfo(
        network: 'btc',
        isValid: true,
        description: 'Bitcoin Native SegWit address',
        metadata: {'format': 'Native SegWit', 'isTestnet': isTestnet},
      );
    }
  }

  // Cosmos
  if (_enabledNetwork(['atom'], allowedNetworks)) {
    final cosmosMatch = Patterns.atom.firstMatch(address);
    if (cosmosMatch != null) {
      final prefix = cosmosMatch.group(
        1,
      ); // Gets the captured group (cosmos|osmo|axelar|juno|stars)
      return NetworkInfo(
        network: 'atom',
        isValid: true,
        description: 'Cosmos ecosystem address',
        metadata: {'chain': prefix, 'format': 'bech32'},
      );
    }
  }

  // Cardano
  if (_enabledNetwork(['ada'], allowedNetworks)) {
    // Check for invalid format first
    if (RegExp(r'^(addr1|addr_test1|stake1|stake_test1)').hasMatch(address)) {
      if (!Patterns.adaMainnet.hasMatch(address) &&
          !Patterns.adaTestnet.hasMatch(address) &&
          !Patterns.adaStake.hasMatch(address) &&
          !Patterns.adaStakeTestnet.hasMatch(address)) {
        return const NetworkInfo(
          network: 'ada',
          isValid: false,
          description: 'Invalid Cardano address format',
        );
      }
    }

    // Shelley mainnet
    if (Patterns.adaMainnet.hasMatch(address)) {
      return const NetworkInfo(
        network: 'ada',
        isValid: true,
        description: 'Cardano Shelley mainnet address',
        metadata: {
          'format': 'bech32',
          'era': 'shelley',
          'type': 'payment',
          'isTestnet': false,
        },
      );
    }

    // Shelley testnet
    if (Patterns.adaTestnet.hasMatch(address)) {
      if (!options.testnet) {
        return const NetworkInfo(
          network: 'ada',
          isValid: false,
          description: 'Testnet address not allowed',
        );
      }
      return const NetworkInfo(
        network: 'ada',
        isValid: true,
        description: 'Cardano Shelley testnet address',
        metadata: {
          'format': 'bech32',
          'era': 'shelley',
          'type': 'payment',
          'isTestnet': true,
        },
      );
    }

    // Stake address
    if (Patterns.adaStake.hasMatch(address)) {
      return const NetworkInfo(
        network: 'ada',
        isValid: true,
        description: 'Cardano stake address',
        metadata: {
          'format': 'bech32',
          'era': 'shelley',
          'type': 'stake',
          'isTestnet': false,
        },
      );
    }

    // Stake testnet address
    if (Patterns.adaStakeTestnet.hasMatch(address)) {
      if (!options.testnet) {
        return const NetworkInfo(
          network: 'ada',
          isValid: false,
          description: 'Testnet address not allowed',
        );
      }
      return const NetworkInfo(
        network: 'ada',
        isValid: true,
        description: 'Cardano stake testnet address',
        metadata: {
          'format': 'bech32',
          'era': 'shelley',
          'type': 'stake',
          'isTestnet': true,
        },
      );
    }
  }

  // Solana - check after other base58 formats to avoid conflicts
  if (_enabledNetwork(['sol'], allowedNetworks)) {
    if (Patterns.sol.hasMatch(address)) {
      // Check for conflicts with other network prefixes
      if (RegExp(
        r'^(cosmos|osmo|axelar|juno|stars|r|bc1|tb1|ltc1|tltc1)',
      ).hasMatch(address)) {
        return const NetworkInfo(
          network: 'sol',
          isValid: false,
          description: 'Invalid address format',
        );
      }
      return NetworkInfo(
        network: 'sol',
        isValid: true,
        description: 'Solana address',
        metadata: {'format': 'base58', 'isTestnet': options.testnet},
      );
    }
  }

  // Polkadot
  if (_enabledNetwork(['dot'], allowedNetworks)) {
    if (Patterns.dot.hasMatch(address)) {
      // Check for conflicts
      if (RegExp(
        r'^(cosmos|osmo|axelar|juno|stars|r|bc1|tb1|ltc1|tltc1)',
      ).hasMatch(address)) {
        return const NetworkInfo(
          network: 'dot',
          isValid: false,
          description: 'Invalid address format',
        );
      }
      return NetworkInfo(
        network: 'dot',
        isValid: true,
        description: 'Polkadot address',
        metadata: {'format': 'ss58', 'isTestnet': options.testnet},
      );
    }
  }

  // Algorand
  if (_enabledNetwork(['algo'], allowedNetworks) &&
      Patterns.algo.hasMatch(address)) {
    return const NetworkInfo(
      network: 'algo',
      isValid: true,
      description: 'Algorand address',
      metadata: {'format': 'base32'},
    );
  }

  // Stellar
  if (_enabledNetwork(['xlm'], allowedNetworks) &&
      Patterns.xlm.hasMatch(address)) {
    return const NetworkInfo(
      network: 'xlm',
      isValid: true,
      description: 'Stellar address',
      metadata: {'format': 'base32', 'type': 'public'},
    );
  }

  // Ripple (XRP) - specific pattern to avoid conflicts
  if (_enabledNetwork(['xrp'], allowedNetworks)) {
    if (Patterns.xrp.hasMatch(address)) {
      return const NetworkInfo(
        network: 'xrp',
        isValid: true,
        description: 'Ripple address',
        metadata: {'format': 'base58', 'isTestnet': false},
      );
    }
  }

  // Tron - check before other base58 formats to avoid conflicts
  if (_enabledNetwork(['trx', 'tron'], allowedNetworks)) {
    final tronLikePattern = RegExp(r'^[A-Z][1-9A-HJ-NP-Za-km-z]{33}$');
    if (address.startsWith('T') || tronLikePattern.hasMatch(address)) {
      if (Patterns.tron.hasMatch(address)) {
        return NetworkInfo(
          network: 'trx',
          isValid: true,
          description: 'Tron address',
          metadata: {'format': 'base58', 'isTestnet': options.testnet},
        );
      }
      return const NetworkInfo(
        network: 'trx',
        isValid: false,
        description: 'Invalid address format',
      );
    }
  }

  // Bitcoin Cash (CashAddr format)
  if (_enabledNetwork(['bch'], allowedNetworks) &&
      Patterns.bchCashAddr.hasMatch(address)) {
    final addr = address.toLowerCase().replaceAll('bitcoincash:', '');
    if (Patterns.bchAddress.hasMatch(addr)) {
      return NetworkInfo(
        network: 'bch',
        isValid: true,
        description: 'Bitcoin Cash CashAddr address',
        metadata: {
          'format': 'CashAddr',
          'isTestnet': addr.startsWith('p'),
          'printFormat': 'bitcoincash:$addr',
          'electronicFormat': addr,
        },
      );
    }
  }

  // Litecoin
  if (_enabledNetwork(['ltc'], allowedNetworks)) {
    // Litecoin Legacy
    if (options.enabledLegacy && Patterns.ltcLegacy.hasMatch(address)) {
      try {
        _validateBase58Check(address);
        return const NetworkInfo(
          network: 'ltc',
          isValid: true,
          description: 'Litecoin Legacy address',
          metadata: {'format': 'Legacy', 'isTestnet': false},
        );
      } catch (_) {
        return const NetworkInfo(
          network: 'ltc',
          isValid: false,
          description: 'Invalid Litecoin Legacy address',
        );
      }
    }

    // Litecoin SegWit
    if (Patterns.ltcSegwit.hasMatch(address)) {
      try {
        _validateBase58Check(address);
        return const NetworkInfo(
          network: 'ltc',
          isValid: true,
          description: 'Litecoin SegWit address',
          metadata: {'format': 'SegWit', 'isTestnet': false},
        );
      } catch (_) {
        return const NetworkInfo(
          network: 'ltc',
          isValid: false,
          description: 'Invalid Litecoin SegWit address',
        );
      }
    }

    // Litecoin Native SegWit
    if (Patterns.ltcNativeSegwit.hasMatch(address)) {
      final isTestnet = address.startsWith('tltc1');
      if (isTestnet && !options.testnet) {
        return const NetworkInfo(
          network: 'ltc',
          isValid: false,
          description: 'Testnet address not allowed',
        );
      }
      return NetworkInfo(
        network: 'ltc',
        isValid: true,
        description: 'Litecoin Native SegWit address',
        metadata: {'format': 'Native SegWit', 'isTestnet': isTestnet},
      );
    }
  }

  // If no matches found
  return const NetworkInfo(
    network: null,
    isValid: false,
    description: 'Unknown address format',
  );
}

NetworkInfo? _validateOptions(ValidationOptions options) {
  // Validate network option
  if (options.network != null && options.network!.isNotEmpty) {
    return const NetworkInfo(
      network: null,
      isValid: false,
      description: 'Invalid options: network array must contain only strings',
    );
  }

  return null;
}

bool _validateEVMChecksum(String address, bool forceValidation) {
  if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address)) {
    return false;
  }

  // Skip validation for all-lowercase/uppercase unless forced
  if (!forceValidation &&
      (address == address.toLowerCase() || address == address.toUpperCase())) {
    return true;
  }

  final stripAddress = address.substring(2);
  final addressBytes = utf8.encode(stripAddress.toLowerCase());
  final hashBytes = sha256.convert(addressBytes).bytes;
  final addressHash = hex.encode(hashBytes);

  for (var i = 0; i < 40; i++) {
    final hashChar = int.parse(addressHash[i], radix: 16);
    final addressChar = stripAddress[i];
    if ((hashChar > 7 && addressChar.toUpperCase() != addressChar) ||
        (hashChar <= 7 && addressChar.toLowerCase() != addressChar)) {
      return false;
    }
  }

  return true;
}

bool _validateICANChecksum(String address) {
  address = address.toUpperCase();
  final rearranged = '${address.substring(4)}${address.substring(0, 4)}';

  final converted = rearranged.split('').map((char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) ? (code - 55).toString() : char;
  }).join('');

  var remainder = converted;
  while (remainder.length > 2) {
    final block = remainder.substring(
      0,
      remainder.length >= 9 ? 9 : remainder.length,
    );
    remainder =
        '${BigInt.parse(block) % BigInt.from(97)}${remainder.substring(block.length)}';
  }

  return int.parse(remainder) % 97 == 1;
}

bool _enabledNetwork(List<String> networks, List<String> allowedNetworks) {
  if (allowedNetworks.isEmpty) {
    return true;
  }
  return networks.any((network) => allowedNetworks.contains(network));
}

String _formatICANAddress(String address) {
  final upperAddress = address.toUpperCase();
  final chunks = <String>[];
  for (var i = 0; i < upperAddress.length; i += 4) {
    final end = i + 4;
    chunks.add(
      upperAddress.substring(
        i,
        end > upperAddress.length ? upperAddress.length : end,
      ),
    );
  }
  return chunks.join('\u00A0');
}

void _validateBase58Check(String address) {
  if (!Base58Check.validate(address)) {
    throw Exception('Invalid Base58Check address');
  }
}
