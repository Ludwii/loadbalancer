FROM ruby:3.4

WORKDIR /usr/src/app
COPY . .
RUN bundle install

EXPOSE 8000
CMD ["ruby", "start_loadbalancer.rb", "config_compose.yaml"]