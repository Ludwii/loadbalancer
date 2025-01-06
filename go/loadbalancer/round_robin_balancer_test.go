package main

import (
	"net"
	"testing"
	"time"
)

func TestNewRoundRobinBalancer(t *testing.T) {
	servers := []string{"127.0.0.1:8081", "127.0.0.1:8082"}
	timeout := 5 * time.Second
	rrb := NewRoundRobinBalancer(servers, timeout)

	if len(rrb.servers) != len(servers) {
		t.Errorf("Expected %d servers, got %d", len(servers), len(rrb.servers))
	}

	for i, server := range rrb.servers {
		expectedAddress := servers[i]
		if server.Address() != expectedAddress {
			t.Errorf("Expected server address %s, got %s", expectedAddress, server.Address())
		}
	}

	if rrb.timeout != timeout {
		t.Errorf("Expected timeout %s, got %s", timeout, rrb.timeout)
	}
}

func TestRoundRobinBalancer_NextServer(t *testing.T) {
	servers := []string{"127.0.0.1:8081", "127.0.0.1:8082"}
	timeout := 5 * time.Second
	rrb := NewRoundRobinBalancer(servers, timeout)

	// Mark all servers as healthy
	for _, server := range rrb.servers {
		server.Healthy = true
	}

	server1, err := rrb.NextServer()
	if err != nil {
		t.Fatalf("Unexpected error: %v", err)
	}
	if server1.Address() != "127.0.0.1:8081" {
		t.Errorf("Expected server address 127.0.0.1:8081, got %s", server1.Address())
	}

	server2, err := rrb.NextServer()
	if err != nil {
		t.Fatalf("Unexpected error: %v", err)
	}
	if server2.Address() != "127.0.0.1:8082" {
		t.Errorf("Expected server address 127.0.0.1:8082, got %s", server2.Address())
	}

	server3, err := rrb.NextServer()
	if err != nil {
		t.Fatalf("Unexpected error: %v", err)
	}
	if server3.Address() != "127.0.0.1:8081" {
		t.Errorf("Expected server address 127.0.0.1:8081, got %s", server3.Address())
	}
}

func TestRoundRobinBalancer_HealthCheck(t *testing.T) {
	servers := []string{"127.0.0.1:8081", "127.0.0.1:8082"}
	timeout := 5 * time.Second
	rrb := NewRoundRobinBalancer(servers, timeout)
	rrb.servers[0].Healthy = true
	rrb.servers[1].Healthy = false

	mockedBackend, err := net.Listen("tcp", "127.0.0.1:8081")
	if err != nil {
		t.Fatalf("Failed to start mock backend server: %v", err)
	}
	defer mockedBackend.Close()

	rrb.HealthCheck()

	if !rrb.servers[0].Healthy {
		t.Errorf("Expected server 127.0.0.1:8081 to be healthy")
	}

	if rrb.servers[1].Healthy {
		t.Errorf("Expected server 127.0.0.1:8082 to be unhealthy")
	}
}

func TestRoundRobinBalancer_HealthyServerCount(t *testing.T) {
	servers := []string{"127.0.0.1:8081", "127.0.0.1:8082"}
	timeout := 5 * time.Second
	rrb := NewRoundRobinBalancer(servers, timeout)

	rrb.servers[0].Healthy = false
	rrb.servers[1].Healthy = true

	count := rrb.HealthyServerCount()
	if count != 1 {
		t.Errorf("Expected 1 healthy server, got %d", count)
	}

	rrb.servers[0].Healthy = true

	count = rrb.HealthyServerCount()
	if count != 2 {
		t.Errorf("Expected 2 healthy servers, got %d", count)
	}
}
