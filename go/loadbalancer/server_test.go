package main

import (
	"net"
	"testing"
	"time"
)

func TestAddress(t *testing.T) {
	server := NewServer("127.0.0.1", "8080")
	expectedAddress := "127.0.0.1:8080"
	if server.Address() != expectedAddress {
		t.Errorf("expected Address to be '%s', got %s", expectedAddress, server.Address())
	}
}

func TestCheckHealth(t *testing.T) {
	listener, err := net.Listen("tcp", "127.0.0.1:8080")
	if err != nil {
		t.Fatalf("failed to start dummy server: %v", err)
	}

	server := NewServer("127.0.0.1", "8080")
	server.CheckHealth(1 * time.Second)
	if !server.Healthy {
		t.Errorf("expected Healthy to be true, got %v", server.Healthy)
	}

	listener.Close()

	server.CheckHealth(1 * time.Second)
	if server.Healthy {
		t.Errorf("expected Healthy to be false, got %v", server.Healthy)
	}
}
