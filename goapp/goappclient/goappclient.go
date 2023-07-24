package main

import (
	"context"
	"log"
	"time"

	pb "github.com/Babbili/k8s-envoylb-cilium/goapp/proto"
	"google.golang.org/grpc"
)

var (
	address = "127.0.0.1:50051"
)

func main() {

	conn, err := grpc.Dial(address, grpc.WithInsecure(), grpc.WithBlock())
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewGoappClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	var new_users = make(map[string]int32)
	new_users["Adam"] = 27
	new_users["Aaron"] = 34
	for name, age := range new_users {
		r, err := c.CreateNewUser(ctx, &pb.NewUser{Name: name, Age: age})
		if err != nil {
			log.Fatalf("could not create user: %v", err)
		}
		log.Printf(`User Details: NAME: %s, AGE: %d, ID: %d`, r.GetName(), r.GetAge(), r.GetId())
	}
}
