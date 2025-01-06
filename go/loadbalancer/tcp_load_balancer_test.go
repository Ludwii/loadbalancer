package main

import (
	"io"
	"net"
	"testing"
	"time"
)

func getTestConfig() map[string]interface{} {
	return map[string]interface{}{
		"listen_host":           "127.0.0.1",
		"listen_port":           "8080",
		"backend_servers":       []string{"127.0.0.1:8081", "127.0.0.1:8082"},
		"timeout":               5,
		"health_check_interval": 10,
	}
}

func TestNewTCPLoadBalancer(t *testing.T) {
	config := getTestConfig()

	lb := NewTCPLoadBalancer(config)

	if lb.listenHost != "127.0.0.1" {
		t.Errorf("Expected listenHost to be '127.0.0.1', got %s", lb.listenHost)
	}
	if lb.listenPort != "8080" {
		t.Errorf("Expected listenPort to be '8080', got %s", lb.listenPort)
	}
	if lb.healthCheckInterval != time.Duration(10)*time.Second {
		t.Errorf("Expected healthCheckInterval to be 10 seconds, got %s", lb.healthCheckInterval)
	}
}

func TestTCPLoadBalancer_StartStop(t *testing.T) {
	config := getTestConfig()

	lb := NewTCPLoadBalancer(config)

	go lb.Start()
	time.Sleep(100 * time.Millisecond) // Let the server start

	conn, err := net.Dial("tcp", "127.0.0.1:8080")
	if err != nil {
		t.Fatalf("Failed to connect to load balancer: %v", err)
	}
	conn.Close()

	lb.Stop()
	time.Sleep(100 * time.Millisecond) // Let the server stop

	_, err = net.Dial("tcp", "127.0.0.1:8080")
	if err == nil {
		t.Fatalf("Expected connection to fail after stopping load balancer")
	}
}

func TestTCPLoadBalancer_handleConnectionWithFailover(t *testing.T) {
	config := getTestConfig()

	lb := NewTCPLoadBalancer(config)

	mockedBackend, err := net.Listen("tcp", "127.0.0.1:8081")
	if err != nil {
		t.Fatalf("Failed to start mock backend server: %v", err)
	}
	defer mockedBackend.Close()

	go func() {
		for {
			conn, err := mockedBackend.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				io.Copy(c, c)
			}(conn)
		}
	}()

	go lb.Start()
	time.Sleep(100 * time.Millisecond) // Let the server start

	clientConn, err := net.Dial("tcp", "127.0.0.1:8080")
	if err != nil {
		t.Fatalf("Failed to connect to load balancer: %v", err)
	}
	defer clientConn.Close()

	clientConn.Write([]byte("test"))
	buf := make([]byte, 4)
	clientConn.Read(buf)
	if string(buf) != "test" {
		t.Errorf("Expected 'test' response, got %s", string(buf))
	}

	lb.Stop()
}
