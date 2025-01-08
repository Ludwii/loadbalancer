# Golang Client

A client application that connects to a TCP socket to simulate traffic written in Golang. The client is continuously connects in an endless loop, whereby an interval between connections can be configured.

## Requirements

To run this application, you need to have Golang and Docker installed on your system. You can check whether you have the necessary installations by executing these statements:
```sh
## Verify your Docker installation
docker --version
## Verify your Golang installation
go version
```

You can install the requirements by executing the following commands (on Ubuntu OS):
```sh
sudo apt install docker-ce
sudo apt install docker-ce-cli
sudo apt install golang-go
```

## Run with Docker

first you need to build the docker container.
This command builds the docker image with the tag `go-client`.
```sh
docker build -t go-client .
```

Afterwards you can run the Docker container like this.
```sh
docker run go-client
```

If you want to override the arguments to the `go-client` executeable, you can do it this way:
```sh
docker run go-client ./go-client -address 127.0.0.1:8000 -sleep_interval 5000
```

## Run locally

install golang and verify the installation (use a package manager depending on your OS):
```sh
sudo apt install golang-go
go version
```

build the project in the current folder:
```sh
go build
```

Run the executable. Additionally, you can fill in the arguments `<address>` with the server address in the string format "127.0.0.1:8000" and `<sleep_interval>` with the sleep interval between client runs in milliseconds as integer. Default values are 127.0.0.1:8000 for the address and 5000 for the sleep interval.
```sh
./go-client -address <address> -sleep_interval <sleep_interval>
```

## Execute tests

To execute the tests for this Golang project, you can use the built-in testing tool provided by Golang. Run the following command to execute all tests in this directory:
```sh
go test
```

