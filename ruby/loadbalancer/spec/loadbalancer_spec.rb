require 'rspec'
require 'socket'
require_relative '../loadbalancer'
require_relative 'mock_server'

RSpec.describe TCPRoundRobinLoadBalancer do
  let(:config) do
    {
      'listen_port' => 8080,
      'backend_servers' => ['127.0.0.1:8081', '127.0.0.1:8082'],
      'timeout' => 5,
      'health_check_interval' => 0.01
    }
  end

  let(:load_balancer) { TCPRoundRobinLoadBalancer.new(config) }

  let(:mock_client) { instance_double('Client', close: nil, puts: nil) }

  let(:mock_tcp_server) { instance_double('TCPServer', accept: mock_client, close: nil) }

  before do
    allow(TCPServer).to receive(:new).and_return(mock_tcp_server)
    allow(load_balancer).to receive(:run_health_checks).and_return(nil)
  end

  describe '#start' do
    it 'starts the load balancer and stops cleanly' do
      server_thread = Thread.new { load_balancer.start }
      sleep 0.1
      load_balancer.stop
      server_thread.join
      expect(load_balancer.instance_variable_get(:@shutdown)).to be true
    end
  end

  describe '#handle_connection_with_failover' do
    before do
      allow(load_balancer).to receive(:next_server).and_return(MockServer.new('127.0.0.1', '8000'))
    end

    it 'redirects the connection to the backend server and closes the client connection' do
      expect(mock_client).to receive(:close)
      load_balancer.send(:handle_connection_with_failover, mock_client)
    end
  end
end
