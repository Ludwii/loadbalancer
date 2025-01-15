require 'socket'
require_relative '../TCPLoadBalancer'
require_relative '../RoundRobinBalancer'

RSpec.describe TCPLoadBalancer do
  let(:config) do
    {
      'listen_host' => '0.0.0.0',
      'listen_port' => 8080,
      'backend_servers' => [
        '127.0.0.1:8081',
        '127.0.0.1:8082'
      ],
      'timeout' => 5,
      'health_check_interval' => 2
    }
  end

  subject { TCPLoadBalancer.new(config) }

  describe '#initialize' do
    it 'initializes with correct attributes' do
      expect(subject.instance_variable_get(:@listen_port)).to eq(8080)
      expect(subject.instance_variable_get(:@load_balancer)).to be_a(RoundRobinBalancer)
      expect(subject.instance_variable_get(:@health_check_interval)).to eq(2)
      expect(subject.instance_variable_get(:@shutdown)).to be false
    end
  end

  describe '#start and #stop' do
    it 'starts and stops the load balancer' do
      thread = Thread.new { subject.start }
      sleep 1
      expect(subject.instance_variable_get(:@server)).not_to be_nil
      expect(subject.instance_variable_get(:@health_check_task)).not_to be_nil

      subject.stop
      expect(subject.instance_variable_get(:@server).closed?).to be true
      thread.kill
    end
  end

  describe '#handle_connection_with_failover' do
    it 'handles connection failover and returns 503 if all servers fail' do
      client = instance_double('TCPSocket')
      allow(client).to receive(:puts).with("503 Service Unavailable")
      allow(client).to receive(:close)
      allow(client).to receive(:closed?).and_return(false)

      allow(subject.instance_variable_get(:@load_balancer)).to receive(:next_server).and_return(nil)
      subject.send(:handle_connection_with_failover, client)

      expect(client).to have_received(:puts).with("503 Service Unavailable")
      expect(client).to have_received(:close)
    end
  end

  describe '#relay_data' do
    it 'relays data between client and backend server' do
      client = instance_double('TCPSocket')
      backend_server = instance_double('TCPSocket')

      allow(client).to receive(:closed?).and_return(false, false, true)
      allow(backend_server).to receive(:closed?).and_return(false, false, true)
      allow(IO).to receive(:select).and_return([[client]], nil)
      allow(client).to receive(:read_nonblock).and_return("data")
      allow(backend_server).to receive(:write_nonblock)

      subject.send(:relay_data, client, backend_server)

      expect(client).to have_received(:read_nonblock).with(4096)
      expect(backend_server).to have_received(:write_nonblock).with("data")
    end
  end

end