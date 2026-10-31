import 'package:uuid/uuid.dart';

class PaymentMutation {
  final double amount;
  final String currency;
  final String recipientId;
  final String recipientName;

  PaymentMutation({
    required this.amount,
    required this.currency,
    required this.recipientId,
    required this.recipientName,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'recipientId': recipientId,
    'recipientName': recipientName,
  };
}

class QueuedMutation {
  final String id;
  final String entityType;
  final String action;
  final Map<String, dynamic> payload;
  final Map<String, int> vectorClock;
  final String status;
  final DateTime createdAt;

  QueuedMutation({
    required this.id,
    required this.entityType,
    required this.action,
    required this.payload,
    required this.vectorClock,
    required this.status,
    required this.createdAt,
  });
}

class OfflineMutationQueue {
  final String deviceId;
  final Map<String, int> _vectorClock = {};
  final List<QueuedMutation> _queue = [];

  OfflineMutationQueue({required this.deviceId});

  String generateIdempotencyKey() {
    return 'paypulse_${deviceId}_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}';
  }

  Future<QueuedMutation> enqueueMutation(PaymentMutation payment) async {
    _vectorClock[deviceId] = (_vectorClock[deviceId] ?? 0) + 1;

    final queued = QueuedMutation(
      id: generateIdempotencyKey(),
      entityType: 'PAYMENT_LEDGER',
      action: 'SETTLE_TRANSFER',
      payload: payment.toJson(),
      vectorClock: Map.from(_vectorClock),
      status: 'pending_sync',
      createdAt: DateTime.now().toUtc(),
    );

    _queue.add(queued);
    return queued;
  }
}