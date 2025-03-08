import 'package:flutter/material.dart';
import 'package:flutter_wallet_validator/flutter_wallet_validator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Wallet Validator Example')),
        body: const WalletValidatorDemo(),
      ),
    );
  }
}

class WalletValidatorDemo extends StatefulWidget {
  const WalletValidatorDemo({super.key});

  @override
  State<WalletValidatorDemo> createState() => _WalletValidatorDemoState();
}

class _WalletValidatorDemoState extends State<WalletValidatorDemo> {
  final _controller = TextEditingController();
  NetworkInfo? _result;

  void _validateAddress() {
    final result = validateWalletAddress(
      _controller.text,
      options: const ValidationOptions(
        network: null, // validate all networks
        testnet: true, // allow testnet addresses
      ),
    );
    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Enter wallet address',
              hintText: 'e.g., 0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _validateAddress,
            child: const Text('Validate'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Network: ${_result!.network ?? 'Unknown'}'),
                    Text('Valid: ${_result!.isValid}'),
                    Text('Description: ${_result!.description ?? 'N/A'}'),
                    if (_result!.metadata != null)
                      Text('Metadata: ${_result!.metadata}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
