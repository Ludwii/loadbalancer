package main

import (
	"flag"
	"log"
	"net"
)

func main() {
	address := flag.String("address", "127.0.0.1:8001", "Server address in the format ip:port")
	flag.Parse()
	host, port, err := net.SplitHostPort(*address)
	if err != nil {
		log.Fatalf("Invalid address format: %v\n", err)
	}

	server := NewServer(host, port)
	server.Start()
}
