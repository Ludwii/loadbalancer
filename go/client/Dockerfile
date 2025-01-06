FROM golang:1.23-alpine3.21
WORKDIR /app
COPY . .
RUN go build -o go-client

CMD ["./go-client"]