package main

import (
	"bufio"
	"flag"
	"io"
	"log"
	"net"
)

type Client struct {
	host string
	port string
}

func NewClient(host, port string) *Client {
	return &Client{host: host, port: port}
}

func (c *Client) Run() {
	conn, err := net.Dial("tcp", c.host+":"+c.port)
	if err != nil {
		log.Printf("Failed to connect to the server on %s:%s. Ensure the server is running.\n", c.host, c.port)
		return
	}
	defer conn.Close()

	log.Printf("Connected to the server at %s:%s\n", c.host, c.port)
	log.Println("Waiting for messages from the server...")

	reader := bufio.NewReader(conn)
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				log.Println("Server closed the connection.")
				break
			}
			log.Printf("Error reading from server: %v\n", err)
			break
		}
		log.Printf("Received: %s\n", line)
	}

	log.Println("Connection closed.")
}

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
