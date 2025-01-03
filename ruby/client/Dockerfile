FROM ruby:3.4

WORKDIR /usr/src/app
COPY . .
RUN bundle install

CMD ["ruby", "start_client.rb", "127.0.0.1:8000"]