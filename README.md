# Kubernetes Envoy Proxy L7 load Balancer through Cilium

This is Layer 7 Load Balancing achieved on Kubernetes gRPC Go services through Cilium embedded Envoy Proxy

<br />

## Install Cilium using Helm

Download the Cilium release tarball and change directory to `cilium-main/install/kubernetes`

```bash
curl -LO https://github.com/cilium/cilium/archive/main.tar.gz && tar xzvf main.tar.gz
cd cilium-main/install/kubernetes
```
> <small>`cilium-main/` and its tar file are added to `.gitignore`</small>

deploy Cilium release via Helm with the following flags
```bash
helm install cilium ./cilium -n kube-system \
    --set kubeProxyReplacement=strict \
    --set loadBalancer.l7.backend=envoy \
    --set-string extraConfig.enable-envoy-config=true

# ---- output ----
NAME: cilium
LAST DEPLOYED: Fri Jul 28 16:14:04 2023
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
You have successfully installed Cilium with Hubble.

Your release version is 1.15.0-dev
```
`KubeProxyReplacement` is the main requirement for the L7 Load-Balancing feature to work


Incase you did not create your Kubernetes cluster with the nodes tainted with `node.cilium.io/agent-not-ready`, then unmanaged pods need to be restarted, 
Restart pods that are not running in `host-networking` mode to ensure that Cilium starts managing them
```bash
kubectl get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTNETWORK:.spec.hostNetwork --no-headers=true | grep '<none>' | awk '{print "-n "$1" "$2}' | xargs -L 1 -r kubectl delete pod
# all pods will have network connectivity provided by Cilium and NetworkPolicy now
```


### Install Cilium CLI

```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64

curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

**enable Hubble**
```bash
cilium hubble enable
```
Hubble is the networking and security observability layer of Cilium


### validate that Cilium has been properly installed
```bash
cilium status --wait

# ------ output ----
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    disabled (using embedded mode)
 \__/¯¯\__/    Hubble Relay:       OK
    \__/       ClusterMesh:        disabled

Deployment             cilium-operator    Desired: 2, Ready: 2/2, Available: 2/2
DaemonSet              cilium             Desired: 4, Ready: 4/4, Available: 4/4
Containers:            cilium             Running: 4
                       cilium-operator    Running: 2
                       hubble-relay       Running: 1

```

Verify `KubeProxyReplacement` and Envoy L7 Load-Balancing enabled

```bash
cilium config view | grep -w "kube-proxy"
cilium config view | grep envoy

# ------ output ---
kube-proxy-replacement                            strict
kube-proxy-replacement-healthz-bind-address
enable-envoy-config                               true
external-envoy-proxy                              false # if set to true Cilium will deploy a seperate managed Envoy Proxy DaemonSet (deault to false, Cilium deploys embedding Envoy Proxy as a seperate proccess)
loadbalancer-l7                                   envoy
```

<br />

## Deploy gRPC Go application

```bash
kubectl apply -f kubernetes-manifests/goappserver-manifests.yaml
kubectl apply -f kubernetes-manifests/goappclient-manifests.yaml
```

*the Go application is goapp client and a server communicating through gRPC. It's expandable to list more services and their messages in `protos/apps.proto` file, then generate Protocol Buffer files with `protoc` command which i included in `proto.sh` files*


Annotate Kubernetes services with `io.cilium.service/lb-l7=enabled` 


```bash
kubectl get cec
# CiliumEnvoyConfig CRDs are created

NAME                                    AGE
cilium-envoy-lb-goappclient             112s
cilium-envoy-lb-goappserver             112s
```


If we observe traffic with `Hubble` it's forwarded to Envoy Proxy
```bash
hubble observe --type trace:to-proxy

# ------- output --
Jul 29 13:13:59.833: apps/goappclient-7dccb64ff6-tmbjz:5000 (ID:13125) -> apps/goappserver-ccbc788bc-gqr4c:50051 (ID:63131) to-proxy FORWARDED (TCP Flags: SYN)
Jul 29 13:13:59.833: apps/goappclient-7dccb64ff6-tmbjz:5000 (ID:13125) -> apps/goappserver-ccbc788bc-gqr4c:50051 (ID:63131) to-proxy FORWARDED (TCP Flags: ACK)
Jul 29 13:13:59.833: apps/goappclient-7dccb64ff6-tmbjz:5000 (ID:13125) -> apps/goappserver-ccbc788bc-gqr4c:50051 (ID:63131) to-proxy FORWARDED (TCP Flags: ACK, PSH)
...
```


