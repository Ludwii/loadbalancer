class Server
  attr_accessor :ip, :port, :healthy

  def initialize(ip, port)
    @ip = ip
    @port = port
    @healthy = true
  end

  def address
    "#{@ip}:#{@port}"
  end

  def check_health(timeout)
    begin
      Timeout.timeout(timeout) do
        TCPSocket.new(@ip, @port).close
        puts "server #{address} healthy"
        @healthy = true
      end
    rescue
      puts "server #{address} unhealthy"
      @healthy = false
    end
  end
end
