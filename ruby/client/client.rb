require 'socket'

def run_receive_only_client(host, port)
  begin
    socket = TCPSocket.new(host, port)
    puts "Connected to the server at #{host}:#{port}"

    puts "Waiting for messages from the server..."
    while line = socket.gets
      puts "Received: #{line}"
    end

  rescue Errno::ECONNREFUSED
    puts "Failed to connect to the server on #{host}:#{port}. Ensure the server is running."
  ensure
    socket&.close
    puts "Connection closed."
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.size != 1
    puts "This ruby script requires to be used with the following arguments: ruby #{__FILE__} <host:port>"
    exit(1)
  end
  
  host, port = ARGV[0].split(":")
  if host.nil? || port.nil?
    puts "Invalid argument format. Expected <host:port>, e.g., 127.0.0.1:3003."
    exit(1)
  end

  run_receive_only_client(host, port.to_i)
end
