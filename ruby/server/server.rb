require 'socket'

def run_server(host, port)
  server = TCPServer.new(host, port)

  request_count = 0
  puts "Server running on #{host}:#{port}"

  loop do
    client = server.accept

    Thread.new(client) do |connection|
      request_count += 1

      connection.puts "Welcome! You are visitor ##{request_count}; Time: #{Time.now}"
      sleep 1

      connection.close
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 1 || !ARGV[0].include?(':')
    puts "Usage: ruby #{__FILE__} <host:port>"
    exit 1
  end

  host, port = ARGV[0].split(':')
  port = port.to_i

  run_server(host, port)
end
