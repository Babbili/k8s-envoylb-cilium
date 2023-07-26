#!/bin/bash

DOCKER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# cd $DOCKER_DIR && docker build -f Dockerfile --tag k8s-envoylb-goappclient ../

# docker scout cves --type image k8s-envoylb-goappclient

# docker run --name k8s-envoylb-goappclient-c k8s-envoylb-goappclient

cd $DOCKER_DIR && docker build -f Dockerfile --tag babbili/k8s-envoylb-goappclient:6aea9c1d ../

docker scout cves --type image babbili/k8s-envoylb-goappclient:6aea9c1d

docker push babbili/k8s-envoylb-goappclient:6aea9c1d
