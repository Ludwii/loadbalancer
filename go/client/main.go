package main

import (
	"flag"
	"log"
	"net"
)

func main() {
	address := flag.String("address", "127.0.0.1:8000", "Server address in the format ip:port")
	flag.Parse()
	host, port, err := net.SplitHostPort(*address)
	if err != nil {
		log.Fatalf("Invalid address format: %v\n", err)
	}

	client := NewClient(host, port)
	client.Run()
}
