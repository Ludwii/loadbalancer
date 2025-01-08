# Golang Backend Server

A server application that exposes to a TCP socket and simulates work when being called written in Golang.

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
This command builds the docker image with the tag `go-backend`.
```sh
docker build -t go-backend .
```

Afterwards you can run the Docker container like this.
```sh
docker run go-backend
```

If you want to override the arguments to the `go-backend` executeable, you can do it this way:
```sh
docker run go-backend ./go-backend -address 127.0.0.1:8001
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

Run the executable. Additionally, you can fill in the argument `<address>` with the server address in the string format "0.0.0.0:8001".  Default values is 127.0.0.1:8001
```sh
./go-backend -address <address>
```

## Execute tests

To execute the tests for this Golang project, you can use the built-in testing tool provided by Golang. Run the following command to execute all tests in this directory:
```sh
go test
```
