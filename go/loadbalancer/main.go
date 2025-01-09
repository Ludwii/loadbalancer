package main

import (
	"flag"
	"log"
)

func main() {
	configFile := flag.String("config", "config_local.yaml", "path to the config file")
	flag.Parse()

	config, err := loadConfig(*configFile)
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	lb := NewTCPLoadBalancer(config)
	lb.Start()
	lb.Stop()
}
