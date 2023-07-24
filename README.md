# Kubernetes Envoy Proxy L7 load Balancer with Cilium


generate pb.go files
```bash
cd goapp
protoc --go_out=proto --go_opt=paths=source_relative --go-grpc_out=proto --go-grpc_opt=paths=source_relative --proto_path=../protos/ ../protos/apps.proto
```



