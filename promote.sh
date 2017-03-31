#!/usr/bin/env bash

# "Promotes" a docker container by re-tagging it with a
# 'release-%date' tag convention.

ID=${1:?Error: You must provide a container ID}
TAG=${2:?Error: You must provide a container tag}
FULL_TAG=$(echo $ID:$TAG)

echo "Pulling $FULL_TAG"
docker pull $FULL_TAG
IMG_ID=$(docker images | grep -m1 -E "$ID\s+$TAG" | awk '{print $3}')
RELEASE_TIME=$(date +%Y-%m-%dT%H-%M-%S)
NEW_TAG=$(echo $FULL_TAG"-release-"$RELEASE_TIME)

echo "Tagging $IMG_ID as $NEW_TAG"
echo docker tag $IMG_ID $NEW_TAG
docker tag $IMG_ID $NEW_TAG

echo "Pushing $NEW_TAG"
docker push $NEW_TAG
