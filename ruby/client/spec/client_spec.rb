require 'socket'
require_relative '../client'

RSpec.describe 'run_receive_only_client' do
  let(:mock_socket) { instance_double('TCPSocket') }

  before do
    allow(TCPSocket).to receive(:new).and_return(mock_socket)
  end

  context 'server accepts connection' do
    it 'receives and prints messages, then closes the connection' do
      allow(mock_socket).to receive(:gets).and_return("Message 1", "Message 2", nil)

      expect(mock_socket).to receive(:close)

      output = capture_output do
        run_receive_only_client('127.0.0.1', 3003)
      end

      expect(output).to include("Message 1")
      expect(output).to include("Message 2")
    end
  end

  context 'server refuses connection' do
    before do
      allow(TCPSocket).to receive(:new).and_raise(Errno::ECONNREFUSED)
    end

    it 'handles the error and does not crash' do
      output = capture_output do
        run_receive_only_client('127.0.0.1', 3003)
      end

      expect(output).to include("Failed to connect to the server")
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