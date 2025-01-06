package main

import (
	"os"

	"gopkg.in/yaml.v2"
)

type Config struct {
	ListenHost          string   `yaml:"listen_host"`
	ListenPort          string   `yaml:"listen_port"`
	BackendServers      []string `yaml:"backend_servers"`
	Timeout             int      `yaml:"timeout"`
	HealthCheckInterval int      `yaml:"health_check_interval"`
}

func loadConfig(filename string) (Config, error) {
	var config Config
	file, err := os.Open(filename)
	if err != nil {
		return config, err
	}
	defer file.Close()

	decoder := yaml.NewDecoder(file)
	err = decoder.Decode(&config)
	return config, err
}
