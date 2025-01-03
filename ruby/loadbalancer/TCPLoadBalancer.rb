require 'socket'
require 'timeout'
require 'yaml'
require 'async'
require_relative 'roundRobinBalancer'

class TCPLoadBalancer
  def initialize(config)
    @listen_host = config['listen_host']
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
    Async do |task|
      @health_check_task = task.async { run_health_checks }

      @server = TCPServer.new(@listen_host, @listen_port)
      puts "Load balancer is listening on port #{@listen_port}..."

      task.async do
        loop do
          break if @shutdown

          begin
            client = @server.accept
            task.async { handle_connection_with_failover(client) }
          rescue IOError, Errno::EBADF => e
            break if @shutdown
            puts "Error accepting client connection: #{e.message}"
          end
        end
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
      relay_data(client, backend_server)
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
      client.close if client && !client.closed?
      backend_server&.close if backend_server && !backend_server.closed?
    end
  end

  def relay_data(client, backend_server)
    sockets = [client, backend_server]
    loop do
      break if sockets.any?(&:closed?)

      ready_sockets = IO.select(sockets)
      break if ready_sockets.nil?

      ready_sockets[0].each do |socket|
        begin
          data = socket.read_nonblock(4096)
          target_socket = (socket == client) ? backend_server : client
          if target_socket && !target_socket.closed?
            target_socket.write_nonblock(data)
          end
        rescue IO::WaitReadable, IO::WaitWritable
          next
        rescue EOFError, IOError, Errno::ECONNRESET, Errno::EPIPE
          socket.close unless socket.closed?
        end
      end
    end
  end
end