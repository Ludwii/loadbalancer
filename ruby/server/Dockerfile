FROM ruby:3.4

WORKDIR /usr/src/app
COPY . .
RUN bundle install

EXPOSE 8001
CMD ["ruby", "start_backend_server.rb", "127.0.0.1:8001"]