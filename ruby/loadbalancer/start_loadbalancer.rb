require 'socket'
require 'timeout'
require 'yaml'
require_relative 'Server'
require_relative 'RoundRobinBalancer'
require_relative 'TCPLoadBalancer'

if __FILE__ == $PROGRAM_NAME
  begin
    config_file = 'config.yaml'
    config = YAML.load_file(config_file)
    load_balancer = TCPLoadBalancer.new(config)
    load_balancer.start
  rescue Errno::ENOENT => e
    puts "Error: Config file not found. #{e.message}"
  rescue StandardError => e
    puts "Error: #{e.message}"
  end
end
