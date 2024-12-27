require 'socket'
require_relative '../server'

RSpec.describe 'run_server' do
  let(:mock_server) { instance_double('TCPServer') }
  let(:mock_client) { instance_double('TCPSocket') }

  before do
    allow(TCPServer).to receive(:new).and_return(mock_server)
    allow(mock_server).to receive(:accept).and_return(mock_client)
    allow(mock_client).to receive(:puts)
    allow(mock_client).to receive(:close)
  end

  it 'starts the server and accepts connections' do
    expect(TCPServer).to receive(:new).with('localhost', 8080)
    expect(mock_server).to receive(:accept)
    
    server_thread = Thread.new { run_server('localhost', 8080) }
    sleep 0.1
    Thread.kill(server_thread)
  end

  it 'sends a welcome message to the client' do
    allow(mock_server).to receive(:accept).and_return(mock_client)
    expect(mock_client).to receive(:puts).with(/Welcome! You are visitor #\d+; Time: /)

    server_thread = Thread.new { run_server('localhost', 8080) }
    sleep 0.1
    Thread.kill(server_thread)
  end

  it 'increments the visitor count' do
    allow(mock_server).to receive(:accept).and_return(mock_client, mock_client, nil)

    visitor_count = 0
    allow(mock_client).to receive(:puts) do |message|
      visitor_count += 1 if message.include?("Welcome!")
    end

    server_thread = Thread.new { run_server('localhost', 8080) }

    sleep 0.2
    Thread.kill(server_thread)

    expect(visitor_count).to be >= 2
  end
end
