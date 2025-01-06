# Startup

## Run with Docker

first you need to build the docker container.
This command builds the docker image with the tag `go-loadbalancer`.
```sh
docker build -t go-loadbalancer .
```

Afterwards you can run the Docker container like this.
```sh
docker run go-loadbalancer
```

If you want to override the arguments to the `go-loadbalancer` executeable, you can do it this way:
```sh
docker run go-loadbalancer ./go-loadbalancer "-config" "config_local.yaml"
```

## Run locally

install golang and verify the installation (use a package manager depending on your OS):
```sh
sudo apt install golang-go
go version
```

to install needed packages execute this statement inside the folder:
```sh
go mod tidy
```

build the project in the current folder:
```sh
go build
```

Run the executable. Additionally, you can fill in the arguments `<config_file_name>` with the name of the config file that the application will use. The config file must reside inside the application folder. The default config used is "config_local.yaml".
```sh
./go-loadbalancer -config <config_file_name>
```

