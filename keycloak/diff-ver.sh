#!/usr/bin/env bash

#set -x
set -e

IMAGE_NAME=$1
IMAGE_TAG1=$2
IMAGE_TAG2=$3
DIFF_SRC_BASE=$4
DIFF_DEST_BASE=$5
DOCKER_RUN_OPTS=$6
CONTAINER_UP_URI=$7

CONTAINER1="$(echo $IMAGE_NAME | tr '/' '_')-$IMAGE_TAG1"
CONTAINER2="$(echo $IMAGE_NAME | tr '/' '_')-$IMAGE_TAG2"

function remove_container()
{
    container=$1
    echo "Removing container $container"
    if docker inspect $container ; then
        docker rm -vf $container
    else
        echo "Container $container is not running"
    fi
}

function export_container()
{
    image_tag=$1
    container=$2
    image="$IMAGE_NAME:$image_tag"

    # Set dest dir name to image name replacing / and : with -
    dest_dir="$DIFF_DEST_BASE/$container"

    mkdir -p "$DIFF_DEST_BASE/$container"

    echo "Removing container $container..."
    remove_container $container

    docker run --detach --name $container $DOCKER_RUN_OPTS $image

    if [[ ! -z $CONTAINER_UP_URI ]]; then
        echo "Waiting for container $container to start..." 
        until $(curl --output /dev/null --silent --head --fail "$CONTAINER_UP_URI"); do
          printf '.'
          sleep 5
        done
    fi

    echo 'Diffing running container filesystem from its image...'
    docker diff $container
     
    echo "Exporting $image:$DIFF_SRC_BASE to $dest_dir..."
    docker cp "$container:$DIFF_SRC_BASE" "$DIFF_DEST_BASE/$container"
    docker stop $container
    docker rm -vf $container
}

echo "Keycloak diff of versions $KC_VER_1 and $KC_VER_2 starting..."

if [[ -d "$DIFF_DEST_BASE" ]]; then
    echo "Cleaning up old diff dir ($DIFF_DEST_BASE)"
    rm -rf "$DIFF_DEST_BASE"
fi

remove_container 'kc_upgrade_db'

docker run --detach --name kc_upgrade_db \
  --env "POSTGRES_DB=keycloak" \
  --env "POSTGRES_USER=keycloak" \
  --env "POSTGRES_PASSWORD=password" \
  postgres:9.6.1

export_container $IMAGE_TAG1 $CONTAINER1
export_container $IMAGE_TAG2 $CONTAINER2

diff -ru "$DIFF_DEST_BASE/$CONTAINER1" "$DIFF_DEST_BASE/$CONTAINER2" > "$DIFF_DEST_BASE/images.diff"

echo "Keycloak diff of versions ${KC_VER_1} and ${KC_VER_2} complete."

