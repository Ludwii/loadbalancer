require 'socket'
require 'timeout'
require 'yaml'
require_relative 'Server'
require_relative 'RoundRobinBalancer'
require_relative 'TCPLoadBalancer'


def get_config()
  if ARGV[0]
    config_file = File.join(File.dirname(__FILE__), ARGV[0])
  else
    default_config_file = File.join(File.dirname(__FILE__), 'config_local.yaml')
    config_file = default_config_file
  end
  config_file
end

if __FILE__ == $PROGRAM_NAME
  begin
    config = YAML.load_file(get_config())
    load_balancer = TCPLoadBalancer.new(config)
    load_balancer.start
  rescue Errno::ENOENT => e
    puts "Error: Config file not found. #{e.message}"
  rescue StandardError => e
    puts "Error: #{e.message}"
  end
end
