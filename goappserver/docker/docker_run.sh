#!/bin/bash

DOCKER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# cd $DOCKER_DIR && docker build -f Dockerfile --tag k8s-envoylb-goappserver ../

# docker scout cves --type image k8s-envoylb-goappserver

# docker run --name k8s-envoylb-goappserver-c k8s-envoylb-goappserver

cd $DOCKER_DIR && docker build -f Dockerfile --tag babbili/k8s-envoylb-goappserver:6aea9c1d ../

docker scout cves --type image babbili/k8s-envoylb-goappserver:6aea9c1d

docker push babbili/k8s-envoylb-goappserver:6aea9c1d
