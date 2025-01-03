# Startup

## Run with Docker

first you need to build the docker container.
This command builds the docker image with the tag `ruby-loadbalancer`.
```sh
docker build -t ruby-loadbalancer .
```

Afterwards you can run the Docker container like this.
```sh
docker run -p 8080:8080 ruby-loadbalancer
```

If you want to override the arguments to the `start_loadbalancer.rb` script, you can do it this way:
```sh
docker run -p 8080:8080 ruby-loadbalancer ruby start_loadbalancer.rb config_local.yaml
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

run this command in this folder; Optional you can fill in the name of a different config file for the loadbalancer in the argument `<optional:config_file>`. Make sure the config file used resides inside the application folder:
```sh
ruby start_loadbalancer.rb <optional:config_file>
```

