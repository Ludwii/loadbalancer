class MockServer
  attr_reader :ip, :port, :healthy

  def initialize(ip, port, healthy = true)
    @ip = ip
    @port = port
    @healthy = healthy
  end

  def healthy?
    @healthy
  end

  def check_health(_timeout)
    true
  end
end