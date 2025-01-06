package main

import (
	"flag"
	"log"
	"net"
	"time"
)

func main() {
	address := flag.String("address", "127.0.0.1:8000", "Server address in the format ip:port")
	sleepInterval := flag.Int("sleep_interval", 5000, "Sleep interval between client runs in milliseconds")
	flag.Parse()
	host, port, err := net.SplitHostPort(*address)
	if err != nil {
		log.Fatalf("Invalid address format: %v\n", err)
	}

	for {
		client := NewClient(host, port)
		client.Run()
		time.Sleep(time.Duration(*sleepInterval) * time.Millisecond)
	}
}
