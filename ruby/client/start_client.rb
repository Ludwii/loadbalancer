require_relative 'client'

# Ensure output is immediately flushed to make logging instantly visible in docker logs
STDOUT.sync = true

if __FILE__ == $PROGRAM_NAME
  if ARGV.size != 1
    puts "error: wrong arguments; useage: ruby #{__FILE__} <host:port>"
    exit(1)
  end
  
  host, port = ARGV[0].split(":")
  if host.nil? || port.nil?
    puts "Invalid argument format. Expected <host:port>, e.g., 127.0.0.1:8000."
    exit(1)
  end

  client = Client.new(host, port.to_i)
  client.run
end
