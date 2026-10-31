import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/sync/offline_mutation_queue.dart';
import 'core/native/biometric_channel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PayPulseApp());
}

class PayPulseApp extends StatelessWidget {
  const PayPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayPulse Mobile Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF09090B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          surface: Color(0xFF18181B),
        ),
      ),
      home: const PayPulseHomeScreen(),
    );
  }
}

class PayPulseHomeScreen extends StatefulWidget {
  const PayPulseHomeScreen({super.key});

  @override
  State<PayPulseHomeScreen> createState() => _PayPulseHomeScreenState();
}

class _PayPulseHomeScreenState extends State<PayPulseHomeScreen> {
  double _balance = 38450.21;
  bool _isSigning = false;
  late final OfflineMutationQueue _queue;

  @override
  void initState() {
    super.initState();
    _queue = OfflineMutationQueue(deviceId: 'dev_pixel8_pro');
  }

  Future<void> _handleTransfer() async {
    final authenticated = await BiometricHardwareBridge.verifyBiometrics(
      reason: 'Authorize instant transfer of \$150.00',
    );

    if (!authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric verification cancelled')),
        );
      }
      return;
    }

    setState(() {
      _isSigning = true;
      _balance -= 150.00;
    });

    final queued = await _queue.enqueueMutation(
      PaymentMutation(amount: 150.00, currency: 'USD', recipientId: 'usr_882', recipientName: 'Sarah Jenkins'),
    );

    await Future.delayed(const Duration(milliseconds: 250));

    if (mounted) {
      setState(() => _isSigning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          content: Text('Transfer queued in Drift ledger! Idempotency: ${queued.id.substring(0, 16)}...'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPulse Mobile Engine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF09090B),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('TOTAL BALANCE', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('\$${_balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isSigning ? null : _handleTransfer,
                icon: const Icon(Icons.fingerprint, color: Colors.black),
                label: Text(_isSigning ? 'Securing Challenge...' : 'Transfer \$150 with Biometrics'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}