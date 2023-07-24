#!/bin/bash

# docker build -f docker/Dockerfile --tag k8s-envoylb-goapp .

# docker scout cves --type image k8s-envoylb-goapp

# docker run --name k8s-envoylb-goapp-c k8s-envoylb-goapp

docker build -f docker/Dockerfile --tag Babbili/k8s-envoylb-goapp:6aea9c1d .

docker scout cves --type image Babbili/k8s-envoylb-goapp:6aea9c1d

docker push babbili/k8s-envoylb-goapp:6aea9c1d
