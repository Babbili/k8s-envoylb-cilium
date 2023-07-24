package main

import (
	"context"
	"log"
	"math/rand"
	"net"

	pb "github.com/Babbili/k8s-envoylb-cilium/goapp/proto"
	"google.golang.org/grpc"
)

var (
	port = ":50051"
)

type GoappServer struct {
	pb.UnimplementedGoappServer
}

func (s *GoappServer) CreateNewUser(ctx context.Context, in *pb.NewUser) (*pb.User, error) {
	log.Printf("Received: %v", in.GetName())
	var user_id int32 = int32(rand.Intn(100))
	return &pb.User{Name: in.GetName(), Age: in.GetAge(), Id: user_id}, nil
}

func main() {
	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	pb.RegisterGoappServer(s, &GoappServer{})
	log.Printf("server listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
