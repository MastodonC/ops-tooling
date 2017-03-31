#!/usr/bin/env bash

# "Promotes" a docker container by re-tagging it with a
# 'release-%date' tag convention.

ID=${1:?Error: You must provide a container ID}
TAG=${2:?Error: You must provide a container tag}
FULL_TAG=$(echo $ID:$TAG)

docker pull $FULL_TAG

if [ $? -eq 0 ]
then
    IMG_ID=$(docker images | grep -m1 -E "$ID\s+$TAG" | awk '{print $3}')
    RELEASE_TIME=$(date +%Y-%m-%dT%H-%M-%S)
    NEW_TAG=$(echo $FULL_TAG"-release-"$RELEASE_TIME)
    docker tag $IMG_ID $NEW_TAG
    docker push $NEW_TAG
    echo $NEW_TAG
else
    exit 1
fi
