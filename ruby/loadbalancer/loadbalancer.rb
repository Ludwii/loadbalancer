require 'socket'
require 'timeout'
require 'yaml'
require_relative 'server'

class RoundRobinLoadBalancer
  def initialize(servers, timeout: 5)
    @servers = servers.map { |s| Server.new(*s.split(':')) }
    @current_index = -1
    @timeout = timeout
  end

  def next_server
    raise "No healthy servers available" if @servers.none?(&:healthy)

    loop do
      @current_index = (@current_index + 1) % @servers.size
      server = @servers[@current_index]
      return server if server.healthy
    end
  end

  def health_check
    @servers.each do |server|
      server.check_health(@timeout)
    end
  end
end

class TCPRoundRobinLoadBalancer
  def initialize(config)
    @listen_port = config['listen_port']
    @load_balancer = RoundRobinLoadBalancer.new(
      config['backend_servers'],
      timeout: config['timeout']
    )
    @health_check_interval = config['health_check_interval']
  end

  def start
    Thread.new { run_health_checks }

    server = TCPServer.new(@listen_port)
    puts "Load balancer is listening on port #{@listen_port}..."

    loop do
      client = server.accept
      Thread.new(client) do |connection|
        handle_connection_with_failover(connection)
      end
    end
  end

  private

  def run_health_checks
    loop do
      sleep @health_check_interval
      puts "Running health checks..."
      @load_balancer.health_check
    end
  end

  def handle_connection_with_failover(client)
    attempt_count = 0

    begin
      attempt_count += 1
      server = @load_balancer.next_server
      puts "Redirecting to #{server.address} (Attempt #{attempt_count})"

      backend_server = TCPSocket.new(server.ip, server.port)

      Thread.new { relay(client, backend_server) }
      relay(backend_server, client)
    rescue => e
      puts "Error: #{e.message}"
      if attempt_count < @load_balancer.instance_variable_get(:@servers).size
        puts "Attempting failover to the next server..."
        retry
      else
        puts "All servers failed. Returning 503 to client."
        client.puts "503 Service Unavailable"
      end
    ensure
      client.close rescue nil
      backend_server&.close rescue nil
    end
  end

  def relay(source, destination)
    loop do
      data = source.readpartial(1024)
      destination.write(data)
    rescue EOFError
      break
    end
  end
end


if __FILE__ == $PROGRAM_NAME
  config_file = 'config.yaml'
  config = YAML.load_file(config_file)
  load_balancer = TCPRoundRobinLoadBalancer.new(config)
  load_balancer.start
end
