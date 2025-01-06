package main

import "flag"

func main() {
	host := flag.String("host", "127.0.0.1", "IP address to bind the server")
	port := flag.String("port", "8001", "Port to bind the server")
	flag.Parse()

	server := NewServer(*host, *port)
	server.Start()
}
