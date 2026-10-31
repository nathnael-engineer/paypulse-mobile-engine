# PayPulse Mobile Engine 💳

High-concurrency cross-platform Flutter mobile wallet with offline transaction queues and Go gRPC distributed ledger.

## Architecture

- **State Management**: BLoC pattern with deterministic immutable states.
- **Offline Ledger**: Encrypted local Drift SQLite database with vector clock synchronization.
- **Biometric Security**: Native Platform Channel querying Apple Secure Enclave & Android KeyStore (< 180ms).
- **Backend Microservices**: Go gRPC distributed ledger engine with Redis atomic idempotency locks.

## Running Tests

```bash
# Run Unit & Widget tests
flutter test

# Run Integration tests on phone/emulator
flutter test integration_test/payment_settlement_flow_test.dart
```

## Building Native Release APK

```bash
flutter pub get
flutter build apk --release
```

Artifact output: `build/app/outputs/flutter-apk/app-release.apk`
