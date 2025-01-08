# Ruby Client

A client application that connects to a TCP socket to simulate traffic written in Ruby. The client is continuously connects in an endless loop, whereby an interval between connections can be configured.

## Requirements

To run this application, you need to have Ruby and Docker installed on your system. You can check whether you have the necessary installations by executing these statements:
```sh
## Verify your Docker installation
docker --version
## Verify your Ruby installation
ruby -v
```

You can install the requirements by executing the following commands (on Ubuntu OS):
```sh
sudo apt install docker-ce
sudo apt install docker-ce-cli
sudo apt install ruby-full
```

## Run with Docker

first you need to build the docker container.
This command builds the docker image with the tag `ruby-client`.
```sh
docker build -t ruby-client .
```

Afterwards you can run the Docker container like this.
```sh
docker run ruby-client
```

If you want to override the arguments to the `start_client.rb` script, you can do it this way:
```sh
docker run ruby-client ruby start_client.rb 127.0.0.1:8000
```

## Run locally

install ruby and verify the installation (use a package manager depending on your OS):
```sh
sudo apt install ruby-full
ruby -v
```

to install needed gems execute this statement inside the folder:
```sh
bundle install
```

This command runs the `start_client.rb` script using Ruby:
```sh
ruby start_client.rb <host>:<port> <optional:sleep_interval>
```
- `<host>:<port>`: Replace `<host>` with the hostname or IP address of the server you want to connect to, and `<port>` with the port number on which the server is listening. If not provided, the default value **127.0.0.1:8000** will be used.
- `<optional:sleep_interval>`: (Optional) Replace this with the number of seconds the client should wait between sending requests to the server. If not provided, the default value **0.5** will be used.

## Execute tests

To execute the tests for this Ruby project, you can use the RSpec testing tool. Run the following command to execute all tests in this directory:
```sh
rspec .\spec\
```
