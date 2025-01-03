require 'socket'

class Client
  def initialize(host, port)
    @host = host
    @port = port
  end

  def run
    begin
      socket = TCPSocket.new(@host, @port)
      puts "Connected to the server at #{@host}:#{@port}"

      puts "Waiting for messages from the server..."
      while line = socket.gets
        puts "Received: #{line}"
      end

    rescue Errno::ECONNREFUSED
      puts "Failed to connect to the server on #{@host}:#{@port}. Ensure the server is running."
    ensure
      socket&.close
      puts "Connection closed."
    end
  end
end
