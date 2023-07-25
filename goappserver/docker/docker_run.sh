#!/bin/bash

# docker build -f docker/Dockerfile --tag k8s-envoylb-goappserver .

# docker scout cves --type image k8s-envoylb-goappserver

# docker run --name k8s-envoylb-goappserver-c k8s-envoylb-goappserver

docker build -f docker/Dockerfile --tag babbili/k8s-envoylb-goappserver:6aea9c1d .

docker scout cves --type image babbili/k8s-envoylb-goappserver:6aea9c1d

docker push babbili/k8s-envoylb-goappserver:6aea9c1d
