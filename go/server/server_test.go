package main

import (
	"net"
	"testing"
)

func TestNewServer(t *testing.T) {
	host := "localhost"
	port := "8001"
	server := NewServer(host, port)

	if server.host != host {
		t.Errorf("Expected host %s, got %s", host, server.host)
	}

	if server.port != port {
		t.Errorf("Expected port %s, got %s", port, server.port)
	}
}

func TestServer_Start_And_Handle_Request(t *testing.T) {
	host := "localhost"
	port := "8001"
	server := NewServer(host, port)

	go server.Start()

	conn, err := net.Dial("tcp", host+":"+port)
	if err != nil {
		t.Fatalf("Failed to connect to server: %v", err)
	}
	defer conn.Close()

	buffer := make([]byte, 1024)
	n, err := conn.Read(buffer)
	if err != nil {
		t.Fatalf("Failed to read from connection: %v", err)
	}

	response := string(buffer[:n])
	expected := "Welcome! You visited host"
	if response[:len(expected)] != expected {
		t.Errorf("Expected response to start with %s, got %s", expected, response)
	}
}
