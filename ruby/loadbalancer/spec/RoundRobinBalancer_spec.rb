require 'rspec'
require_relative '../RoundRobinBalancer'
require_relative '../Server'

describe RoundRobinBalancer do
  let(:servers) { ['127.0.0.1:8080', '127.0.0.1:8081'] }
  let(:balancer) { RoundRobinBalancer.new(servers) }

  describe '#initialize' do
    it 'initializes with a list of servers and a timeout' do
      expect(balancer.instance_variable_get(:@servers).size).to eq(2)
      expect(balancer.instance_variable_get(:@timeout)).to eq(5)
    end
  end

  describe '#next_server' do
    context 'when all servers are healthy' do
      it 'returns the next healthy server' do
        allow_any_instance_of(Server).to receive(:healthy).and_return(true)
        expect(balancer.next_server).to be_a(Server)
      end
    end

    context 'when no servers are healthy' do
      it 'raises an error' do
        allow_any_instance_of(Server).to receive(:healthy).and_return(false)
        expect { balancer.next_server }.to raise_error("No healthy servers available")
      end
    end
  end

  describe '#health_check' do
    it 'checks the health of all servers' do
      servers = balancer.instance_variable_get(:@servers)
      servers.each do |server|
        expect(server).to receive(:check_health).with(5)
      end
      balancer.health_check
    end
  end
end