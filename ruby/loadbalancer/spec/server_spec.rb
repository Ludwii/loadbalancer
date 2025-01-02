require 'rspec'
require 'timeout'
require 'socket'
require_relative '../server'

RSpec.describe Server do
  before(:each) do
    @server = Server.new('127.0.0.1', 8080)
  end

  describe '#initialize' do
    it 'initializes with correct ip and port' do
      expect(@server.ip).to eq('127.0.0.1')
      expect(@server.port).to eq(8080)
      expect(@server.healthy).to be true
    end
  end

  describe '#address' do
    it 'returns the correct address' do
      expect(@server.address).to eq('127.0.0.1:8080')
    end
  end

  describe '#check_health' do
    context 'when the server is healthy' do
      it 'sets healthy to true' do
        socket = instance_double('TCPSocket')
        allow(TCPSocket).to receive(:new).and_return(socket)
        allow(socket).to receive(:close)
        @server.check_health(1)
        expect(@server.healthy).to be true
      end
    end

    context 'when the server is unhealthy' do
      it 'sets healthy to false' do
        allow(TCPSocket).to receive(:new).and_raise(Errno::ECONNREFUSED)
        @server.check_health(1)
        expect(@server.healthy).to be false
      end
    end
  end
end
