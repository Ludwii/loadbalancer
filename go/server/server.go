package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"time"
)

type Server struct {
	host string
	port string
}

func NewServer(host, port string) *Server {
	return &Server{host: host, port: port}
}

func (s *Server) Start() {
	listener, err := net.Listen("tcp", s.host+":"+s.port)
	if err != nil {
		log.Println("Error starting server:", err)
		return
	}
	defer listener.Close()
	log.Printf("Server running on %s:%s\n", s.host, s.port)
	fmt.Printf("Server running on %s:%s\n", s.host, s.port)

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Println("Error accepting connection:", err)
			continue
		}
		go s.handleRequest(conn)
	}
}

func (s *Server) handleRequest(conn net.Conn) {
	// Sleep to simulate some work
	time.Sleep(1 * time.Second)

	response := fmt.Sprintf("Welcome! You visited %s:%s. I did some work and returned this line to you. Time: %s\n",
		s.host, s.port, time.Now().Format(time.RFC1123))
	_, err := conn.Write([]byte(response))
	if err != nil {
		log.Println("Error writing response:", err)
	}

	conn.Close()
}

func main() {
	host := flag.String("host", "127.0.0.1", "IP address to bind the server")
	port := flag.String("port", "8001", "Port to bind the server")
	flag.Parse()

	server := NewServer(*host, *port)
	server.Start()
}
