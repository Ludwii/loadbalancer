require 'socket'
require 'timeout'
require 'yaml'
require_relative 'server'

class RoundRobinBalancer
  def initialize(servers, timeout: 5)
    @servers = servers.map { |server| parse_backend_address(server) }
    @server_enum = @servers.cycle
    @timeout = timeout
  end

  def next_server
    raise "No healthy servers available" if @servers.none?(&:healthy)

    loop do
      server = @server_enum.next
      return server if server.healthy
    end
  end

  def health_check
    @servers.each do |backend_server|
      backend_server.check_health(@timeout)
    end
  end

  private

  def parse_backend_address(server)
    ip, port = server.split(':')
    Server.new(ip, port)
  end
end
