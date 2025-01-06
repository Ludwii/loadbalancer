FROM golang:1.23-alpine3.21
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o go-loadbalancer

CMD ["./go-loadbalancer", "-config", "config_compose.yaml"]
