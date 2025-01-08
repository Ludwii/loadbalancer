# Ruby Backend Server

A server application that exposes to a TCP socket and simulates work when being called written in Ruby.

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
This command builds the docker image with the tag `ruby-backend`.
```sh
docker build -t ruby-backend .
```

Afterwards you can run the Docker container like this.
```sh
docker run -p 8001:8001 ruby-backend
```

If you want to override the arguments to the `start_backend_server.rb` script, you can do it this way. but you might need to expose different ports then:
```sh
docker run -p 8001:8001 ruby-backend ruby start_backend_server.rb 127.0.0.1:8001
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

This command runs the `start_backend_server.rb` script using Ruby:
```sh
ruby start_backend_server.rb <host>:<port>
```
- `<host>:<port>`: Replace `<host>` with the hostname or IP address where the server will run. If not provided, the default value **127.0.0.1:8001** will be used.

## Execute tests

To execute the tests for this Ruby project, you can use the RSpec testing tool. Run the following command to execute all tests in this directory:
```sh
rspec .\spec\
```
