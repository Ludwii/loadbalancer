# Startup

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

