import 'package:flutter_wallet_validator/flutter_wallet_validator.dart';

void main() {
  // Validate an Ethereum address with specific networks enabled
  final evmResult = validateWalletAddress(
    '0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97',
    options: ValidationOptions(network: ['evm', 'eth']),
  );
  print(evmResult);
  // NetworkInfo(
  //   network: 'evm',
  //   isValid: true,
  //   description: 'Ethereum Virtual Machine compatible address (Ethereum, Polygon, BSC, etc.)',
  //   metadata: {
  //     'isChecksumValid': true,
  //     'format': 'hex'
  //   }
  // )

  // Validate a Name Service domain
  final nsResult = validateWalletAddress(
    'vitalik.eth',
    options: ValidationOptions(nsDomains: ['eth'], network: ['ns']),
  );
  print(nsResult);
  // NetworkInfo(
  //   network: 'ns',
  //   isValid: true,
  //   description: 'Name Service domain',
  //   metadata: {
  //     'format': 'ens',
  //     'isSubdomain': false,
  //     'isEmoji': false
  //   }
  // )

  // Validate with multiple options
  final result = validateWalletAddress(
    'tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx',
    options: ValidationOptions(
      network: ['btc'],
      testnet: true,
      enabledLegacy: false,
    ),
  );
  print(result);
  // NetworkInfo(
  //   network: 'bitcoin',
  //   isValid: true,
  //   description: 'Bitcoin Native SegWit address',
  //   metadata: {
  //     'format': 'Native SegWit',
  //     'isTestnet': true
  //   }
  // )
}
