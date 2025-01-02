require 'rspec'
require 'socket'
require_relative '../TCPLoadBalancer'
require_relative '../RoundRobinBalancer'

RSpec.describe TCPLoadBalancer do
  let(:config) do
    {
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
      expect(subject.instance_variable_get(:@health_check_thread).alive?).to be true

      subject.stop
      expect(subject.instance_variable_get(:@server).closed?).to be true
      expect(subject.instance_variable_get(:@health_check_thread).alive?).to be false
      thread.kill
    end
  end

  describe '#handle_connection_with_failover' do
    it 'handles connection failover and returns 503 if all servers fail' do
      client = instance_double('TCPSocket')
      allow(client).to receive(:puts).with("503 Service Unavailable")

      allow(subject.instance_variable_get(:@load_balancer)).to receive(:next_server).and_return(nil)
      subject.send(:handle_connection_with_failover, client)

      expect(client).to have_received(:puts).with("503 Service Unavailable")
    end
  end

  describe '#relay_data' do
    it 'relays data between source and destination' do
      source = instance_double('TCPSocket')
      destination = instance_double('TCPSocket')

      allow(source).to receive(:gets).and_return("data", nil)
      allow(destination).to receive(:puts).with("data")
      allow(destination).to receive(:puts).with(nil)
      allow(source).to receive(:close)
      allow(destination).to receive(:close)

      subject.send(:relay_data, source, destination)

      expect(source).to have_received(:gets).twice
      expect(destination).to have_received(:puts).with("data").once
      expect(destination).to have_received(:puts).with(nil).once
      expect(source).to have_received(:close).once
      expect(destination).to have_received(:close).once
    end
  end
end