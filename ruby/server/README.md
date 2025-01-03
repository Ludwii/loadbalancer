# Startup

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

run the command in this folder; Make sure to fill in the arguments `<host>` and `<port>`:
```sh
ruby start_backend_server.rb <host>:<port>
```
