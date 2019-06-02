SERVER_OUT := "bin/server"
CLIENT_OUT := "bin/client"
API_OUT := "api/api.pb.go"
PKG := "github.com/Manuhmutua/learning-grpc"

#SERVER_PKG_BUILD := "${PKG}/server"
#CLIENT_PKG_BUILD := "${PKG}/client"

SERVER_PKG_BUILD := "server"
CLIENT_PKG_BUILD := "client"

PKG_LIST := $(shell go list ${PKG}/... | grep -v /vendor/)

.PHONY: all api build_server build_client

all: build_server build_client

api/api.pb.go: api/api.proto
	@protoc -I api/ \
		-I${GOPATH}/src \
		--go_out=plugins=grpc:api \
		api/api.proto

api: api/api.pb.go ## Auto-generate grpc go sources

dep: ## Get the dependencies
	@go get -v -d ./...

build_server: dep api ## Build the binary file for server
	@go build -i -v -o $(SERVER_OUT) $(SERVER_PKG_BUILD)/main.go

build_client: dep api ## Build the binary file for client
	@go build -i -v -o $(CLIENT_OUT) $(CLIENT_PKG_BUILD)/main.go

clean: ## Remove previous builds
	@rm $(SERVER_OUT) $(CLIENT_OUT) $(API_OUT)

generate_ssl: ## Generate SSL for secure connection
	@openssl genrsa -out cert/server.key 2048 && \
    openssl req -new -x509 -sha256 -key cert/server.key -out cert/server.crt -days 3650 && \
    openssl req -new -sha256 -key cert/server.key -out cert/server.csr && \
    openssl x509 -req -sha256 -in cert/server.csr -signkey cert/server.key -out cert/server.crt -days 3650

help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
