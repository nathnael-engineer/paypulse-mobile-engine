import 'package:flutter_test/flutter_test.dart';
import 'package:paypulse_mobile_engine/core/sync/offline_mutation_queue.dart';

void main() {
  group('OfflineMutationQueue Unit Tests', () {
    late OfflineMutationQueue queue;
    const String testDeviceId = 'device_pixel_8_pro';

    setUp(() {
      queue = OfflineMutationQueue(deviceId: testDeviceId);
    });

    test('generateIdempotencyKey produces unique, device-scoped RFC-compliant keys', () {
      final key1 = queue.generateIdempotencyKey();
      final key2 = queue.generateIdempotencyKey();

      expect(key1, startsWith('paypulse_${testDeviceId}_'));
      expect(key2, startsWith('paypulse_${testDeviceId}_'));
      expect(key1, isNot(equals(key2)));
    });

    test('enqueueMutation increments vector clock deterministically', () async {
      final payment = PaymentMutation(
        amount: 250.00,
        currency: 'USD',
        recipientId: 'usr_sarah_90',
        recipientName: 'Sarah Jenkins',
      );

      final mutation1 = await queue.enqueueMutation(payment);
      expect(mutation1.vectorClock[testDeviceId], equals(1));
      expect(mutation1.status, equals('pending_sync'));

      final mutation2 = await queue.enqueueMutation(payment);
      expect(mutation2.vectorClock[testDeviceId], equals(2));
    });
  });
}