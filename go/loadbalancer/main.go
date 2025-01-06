package main

import (
	"log"
)

func main() {
	config, err := loadConfig("config_local.yaml")
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	lb := NewTCPLoadBalancer(config)
	lb.Start()
}
