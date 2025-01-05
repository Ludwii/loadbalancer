package main

import (
	"net"
	"testing"
)

func startTestServer(t *testing.T, port string) net.Listener {
	ln, err := net.Listen("tcp", ":"+port)
	if err != nil {
		t.Fatalf("Failed to start test server: %v", err)
	}
	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				c.Write([]byte("Hello from server\n"))
			}(conn)
		}
	}()
	return ln
}

func TestClientConnection(t *testing.T) {
	port := "8001"
	ln := startTestServer(t, port)
	defer ln.Close()

	client := NewClient("127.0.0.1", port)
	client.Run()
}

func TestClientConnectionFailure(t *testing.T) {
	client := NewClient("127.0.0.1", "9999")
	client.Run()
}

func TestClientReceiveMessage(t *testing.T) {
	port := "8002"
	ln := startTestServer(t, port)
	defer ln.Close()

	client := NewClient("127.0.0.1", port)
	go client.Run()

	conn, err := net.Dial("tcp", "127.0.0.1:"+port)
	if err != nil {
		t.Fatalf("Failed to connect to test server: %v", err)
	}
	defer conn.Close()

	buffer := make([]byte, 1024)
	n, err := conn.Read(buffer)
	if err != nil {
		t.Fatalf("Failed to read from server: %v", err)
	}

	response := string(buffer[:n])
	expected := "Hello from server\n"
	if response != expected {
		t.Errorf("Expected response %s, got %s", expected, response)
	}
}
