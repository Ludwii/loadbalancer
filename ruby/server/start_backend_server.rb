require_relative 'server'

# Ensure output is immediately flushed to make logging instantly visible in docker logs
STDOUT.sync = true

if __FILE__ == $PROGRAM_NAME
    if ARGV.length != 1 || ARGV[0].count(':') != 1
        puts "Usage: ruby #{__FILE__} <host:port>"
        exit 1
    end

    host, port = ARGV[0].split(':')
    port = port.to_i

    server = Server.new(host, port)
    server.start
end
