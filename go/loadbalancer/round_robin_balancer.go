package main

import (
	"errors"
	"strings"
	"sync/atomic"
	"time"
)

type RoundRobinBalancer struct {
	servers []*Server
	index   uint32
	timeout time.Duration
}

func NewRoundRobinBalancer(servers []string, timeout time.Duration) *RoundRobinBalancer {
	backendServers := make([]*Server, len(servers))
	for i, server := range servers {
		backendServers[i] = parseBackendAddress(server)
	}
	return &RoundRobinBalancer{servers: backendServers, timeout: timeout}
}

func (rrb *RoundRobinBalancer) NextServer() (*Server, error) {
	for i := 0; i < len(rrb.servers); i++ {
		index := atomic.AddUint32(&rrb.index, 1) - 1
		server := rrb.servers[index%uint32(len(rrb.servers))]
		if server.Healthy {
			return server, nil
		}
	}
	return nil, errors.New("no healthy servers available")
}

func (rrb *RoundRobinBalancer) HealthCheck() {
	for _, server := range rrb.servers {
		server.CheckHealth(rrb.timeout)
	}
}

func (rrb *RoundRobinBalancer) HealthyServerCount() int {
	count := 0
	for _, server := range rrb.servers {
		if server.Healthy {
			count++
		}
	}
	return count
}

func parseBackendAddress(server string) *Server {
	parts := strings.Split(server, ":")
	return NewServer(parts[0], parts[1])
}
