require 'socket'
require_relative '../client'

RSpec.describe Client do
  let(:host) { '127.0.0.1' }
  let(:port) { 8000 }
  let(:client) { Client.new(host, port) }
  let(:mock_socket) { instance_double('TCPSocket') }

  before do
    allow(TCPSocket).to receive(:new).and_return(mock_socket)
  end

  describe '#run' do
    context 'when the server accepts the connection' do
      it 'receives and prints messages, then closes the connection' do
        allow(mock_socket).to receive(:gets).and_return("Message 1\n", "Message 2\n", nil)
        expect(mock_socket).to receive(:close)

        output = capture_output do
          client.run
        end

        expect(output).to include("Connected to the server")
        expect(output).to include("Waiting for messages from the server...")
        expect(output).to include("Received: Message 1")
        expect(output).to include("Received: Message 2")
        expect(output).to include("Connection closed.")
      end
    end

    context 'when the server refuses the connection' do
      before do
        allow(TCPSocket).to receive(:new).and_raise(Errno::ECONNREFUSED)
      end

      it 'handles the error' do
        output = capture_output do
          client.run
        end

        expect(output).to include("Failed to connect to the server")
        expect(output).to include("Connection closed.")
      end
    end
  end

  def capture_output
    original_stdout = $stdout
    captured_output = StringIO.new
    $stdout = captured_output
    yield
    captured_output.string
  ensure
    $stdout = original_stdout
  end
end
