package main

import (
	"fmt"
	"log"
	"net"
	"time"
)

type Server struct {
	IP      string
	Port    string
	Healthy bool
}

func NewServer(ip, port string) *Server {
	return &Server{IP: ip, Port: port, Healthy: true}
}

func (s *Server) Address() string {
	return fmt.Sprintf("%s:%s", s.IP, s.Port)
}

func (s *Server) CheckHealth(timeout time.Duration) {
	conn, err := net.DialTimeout("tcp", s.Address(), timeout)
	if err != nil {
		log.Printf("server %s unhealthy\n", s.Address())
		s.Healthy = false
		return
	}
	conn.Close()
	log.Printf("server %s healthy\n", s.Address())
	s.Healthy = true
}
