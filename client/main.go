package main

import (
	"google.golang.org/grpc/credentials"
	"log"

	"github.com/Manuhmutua/learning-grpc/api"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

type Authentication struct {
	Login    string
	Password string
}

func (a *Authentication) GetRequestMetadata(context.Context, ...string) (map[string]string, error) {
	return map[string]string{
		"login":    a.Login,
		"password": a.Password,
	}, nil
}

func (a *Authentication) RequireTransportSecurity() bool {
	return true
}


func main() {
	var conn *grpc.ClientConn

	// Create the client TLS credentials
	creds, err := credentials.NewClientTLSFromFile("cert/server.crt", "localhost")
	if err != nil {
		log.Fatalf("could not load tls cert: %s", err)
	}

	auth := Authentication{
		Login:    "john",
		Password: "doe",
	}


	// Initiate a connection with the server
	conn, err = grpc.Dial("localhost:9990", grpc.WithTransportCredentials(creds), grpc.WithPerRPCCredentials(&auth))
	if err != nil {
		log.Fatalf("did not connect: %s", err)
	}
	defer conn.Close()

	c := api.NewPingClient(conn)

	response, err := c.SayHello(context.Background(), &api.PingMessage{Greeting: "foo"})
	if err != nil {
		log.Fatalf("error when calling SayHello: %s", err)
	}
	log.Printf("Response from server: %s", response.Greeting)
}