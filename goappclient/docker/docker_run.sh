#!/bin/bash

# docker build -f docker/Dockerfile --tag k8s-envoylb-goappclient .

# docker scout cves --type image k8s-envoylb-goappclient

# docker run --name k8s-envoylb-goappclient-c k8s-envoylb-goappclient

docker build -f docker/Dockerfile --tag babbili/k8s-envoylb-goappclient:6aea9c1d .

docker scout cves --type image babbili/k8s-envoylb-goappclient:6aea9c1d

docker push babbili/k8s-envoylb-goappclient:6aea9c1d
