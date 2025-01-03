require 'socket'
require_relative '../server'

RSpec.describe Server do
  let(:host) { 'localhost' }
  let(:port) { 8080 }
  let(:server) { Server.new(host, port) }
  let(:mock_server) { instance_double('TCPServer') }
  let(:mock_client) { instance_double('TCPSocket') }

  before do
    allow(TCPServer).to receive(:new).and_return(mock_server)
    allow(mock_server).to receive(:accept).and_return(mock_client)
    allow(TCPSocket).to receive(:new).and_return(mock_client)
  end

  describe '#start' do
    it 'starts the server and accepts connections' do
      expect(TCPServer).to receive(:new).with(host, port)
      expect(mock_server).to receive(:accept)

      server_thread = Thread.new { server.start }
      sleep 0.1
      Thread.kill(server_thread)
    end
  end
end
