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

class TCPLoadBalancer
  def initialize(config)
    @listen_port = config['listen_port']
    @load_balancer = RoundRobinBalancer.new(
      config['backend_servers'],
      timeout: config['timeout']
    )
    @health_check_interval = config['health_check_interval']
    @shutdown = false
    @health_check_thread = nil
    @server = nil
  end

  def start
    @health_check_thread = Thread.new { run_health_checks }

    @server = TCPServer.new("127.0.0.1", @listen_port)
    puts "Load balancer is listening on port #{@listen_port}..."

    loop do
      break if @shutdown

      begin
        client = @server.accept
        Thread.new(client) do |connection|
          handle_connection_with_failover(connection)
        end
      rescue IOError, Errno::EBADF => e
        break if @shutdown
        puts "Error accepting client connection: #{e.message}"
      end
    end
  ensure
    stop
  end

  def stop
    @shutdown = true
    @health_check_thread&.kill
    @server&.close rescue nil
    puts "Load balancer has stopped."
  end

  private

  def run_health_checks
    loop do
      break if @shutdown
      sleep @health_check_interval
      puts "Running health checks..."
      @load_balancer.health_check
    end
  end

  def handle_connection_with_failover(client)
    attempt_count = 0
    backend_server = nil

    begin
      attempt_count += 1
      server = @load_balancer.next_server
      puts "Redirecting to #{server.address} (Attempt #{attempt_count})"

      backend_server = TCPSocket.new(server.ip, server.port)
      Thread.new { relay_data(client, backend_server) }
      Thread.new { relay_data(backend_server, client) }
    rescue => e
      puts "Error: #{e.message}"
      if attempt_count < @load_balancer.instance_variable_get(:@servers).size
        puts "Attempting failover to the next server..."
        retry
      else
        puts "All servers failed. Returning 503 to client."
        client.puts "503 Service Unavailable"
      end
    end
  end

  def relay_data(source, destination)
    loop do
      begin
        data = source.gets
        destination.puts(data)
      rescue IOError, Errno::ECONNRESET
        break
      end
    end
  ensure
    source.close
    destination.close
  end
end

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
