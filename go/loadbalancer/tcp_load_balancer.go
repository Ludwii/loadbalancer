package main

import (
	"context"
	"io"
	"log"
	"net"
	"sync"
	"time"
)

type TCPLoadBalancer struct {
	listenHost           string
	listenPort           string
	loadBalancer         *RoundRobinBalancer
	healthCheckInterval  time.Duration
	shutdown             bool
	healthCheckWaitGroup sync.WaitGroup
	server               net.Listener
}

func NewTCPLoadBalancer(config map[string]interface{}) *TCPLoadBalancer {
	servers := config["backend_servers"].([]string)
	timeout := time.Duration(config["timeout"].(int)) * time.Second
	healthCheckInterval := time.Duration(config["health_check_interval"].(int)) * time.Second

	return &TCPLoadBalancer{
		listenHost:          config["listen_host"].(string),
		listenPort:          config["listen_port"].(string),
		loadBalancer:        NewRoundRobinBalancer(servers, timeout),
		healthCheckInterval: healthCheckInterval,
	}
}

func (lb *TCPLoadBalancer) Start() {
	var err error
	lb.server, err = net.Listen("tcp", lb.listenHost+":"+lb.listenPort)
	if err != nil {
		log.Println("Error starting server:", err)
		return
	}
	defer lb.server.Close()

	log.Printf("Load balancer is listening on port %s...\n", lb.listenPort)

	lb.healthCheckWaitGroup.Add(1)
	go lb.runHealthChecks()

	for {
		if lb.shutdown {
			break
		}

		conn, err := lb.server.Accept()
		if err != nil {
			if lb.shutdown {
				break
			}
			log.Println("Error accepting client connection:", err)
			continue
		}
		go lb.handleConnectionWithFailover(conn)
	}
}

func (lb *TCPLoadBalancer) Stop() {
	lb.shutdown = true
	lb.server.Close()
	lb.healthCheckWaitGroup.Wait()
	log.Println("Load balancer has stopped.")
}

func (lb *TCPLoadBalancer) runHealthChecks() {
	defer lb.healthCheckWaitGroup.Done()
	ticker := time.NewTicker(lb.healthCheckInterval)
	defer ticker.Stop()

	for range ticker.C {
		if lb.shutdown {
			return
		}
		log.Println("Running health checks...")
		lb.loadBalancer.HealthCheck()
	}
}

func (lb *TCPLoadBalancer) handleConnectionWithFailover(client net.Conn) {
	defer client.Close()

	attemptCount := 0
	var backendServer net.Conn

	for {
		attemptCount++
		server, err := lb.loadBalancer.NextServer()
		if err != nil {
			log.Println("All servers failed. Returning 503 to client.")
			client.Write([]byte("503 Service Unavailable\n"))
			return
		}

		if attemptCount > lb.loadBalancer.HealthyServerCount() {
			log.Println("Exceeded maximum retry attempts. Returning 503 to client.")
			client.Write([]byte("503 Service Unavailable\n"))
			return
		}

		log.Printf("Redirecting to %s (Attempt %d)\n", server.Address(), attemptCount)
		backendServer, err = net.Dial("tcp", server.Address())
		if err == nil {
			break
		}
		log.Println("Error:", err)
	}

	defer backendServer.Close()
	lb.relayData(client, backendServer)
}

func (lb *TCPLoadBalancer) relayData(client, backendServer net.Conn) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()
		io.Copy(backendServer, client)
		cancel()
	}()

	go func() {
		defer wg.Done()
		io.Copy(client, backendServer)
		cancel()
	}()

	waitForCompletion(ctx, &wg)
}

func waitForCompletion(ctx context.Context, wg *sync.WaitGroup) {
	select {
	case <-ctx.Done():
	case <-func() chan struct{} {
		done := make(chan struct{})
		go func() {
			wg.Wait()
			close(done)
		}()
		return done
	}():
	}
}

func main() {
	config := map[string]interface{}{
		"listen_host":           "127.0.0.1",
		"listen_port":           "8000",
		"backend_servers":       []string{"127.0.0.1:8001", "127.0.0.1:8002"},
		"timeout":               5,
		"health_check_interval": 10,
	}

	lb := NewTCPLoadBalancer(config)
	lb.Start()
}
