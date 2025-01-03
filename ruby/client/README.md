# Startup

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

run this command in the underlying folder; Make sure to fill in the arguments `<host>` and `<port>`:
```sh
ruby start_client.rb <host>:<port>
```

