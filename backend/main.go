package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"sync"
	"time"

	"google.golang.org/grpc"
)

type PaymentServer struct {
	mu          sync.RWMutex
	idempotency map[string]*TransactionReceipt
	balances    map[string]float64
}

type TransactionReceipt struct {
	ReceiptID string
	Status    string
	Balance   float64
	Timestamp time.Time
}

func (s *PaymentServer) SettlePayment(ctx context.Context, key, senderID, recipientID string, amount float64) (*TransactionReceipt, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if receipt, exists := s.idempotency[key]; exists {
		log.Printf("[Idempotency Hit] Key: %s -> %s", key, receipt.ReceiptID)
		return receipt, nil
	}

	s.balances[senderID] -= amount
	s.balances[recipientID] += amount

	receipt := &TransactionReceipt{
		ReceiptID: fmt.Sprintf("rcpt_%d", time.Now().UnixNano()),
		Status:    "SETTLED",
		Balance:   s.balances[senderID],
		Timestamp: time.Now().UTC(),
	}

	s.idempotency[key] = receipt
	return receipt, nil
}

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("Failed to listen on 50051: %v", err)
	}
	grpcServer := grpc.NewServer()
	log.Printf("PayPulse Go gRPC Ledger listening on :50051")
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve gRPC: %v", err)
	}
}