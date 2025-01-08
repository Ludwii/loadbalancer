require 'socket'

class Server
  def initialize(host, port)
    @host = host
    @port = port
  end

  def start
    server = TCPServer.new(@host, @port)
    puts "Server running on #{@host}:#{@port}"
    
    loop do
      client = server.accept
      Thread.new(client) do |connection|
        handle_request(connection)
      end
    end
  end

  private

  def handle_request(connection)
    # Sleep to simulate some work
    sleep 1

    hostname = Socket.gethostname
    connection.puts "Welcome! You visited host #{hostname}. " \
            "I did some work and returned this line to you. " \
            "Time: #{Time.now}"
    connection.close
  end
end
