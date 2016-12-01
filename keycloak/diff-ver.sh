#!/usr/bin/env bash

KC_VER=$1
echo "Keycloak Version: $KC_VER"

set -x

docker rm -vf kc_upgrade kc_upgrade_db

set -e

docker run --detach --name kc_upgrade_db \
  --env "POSTGRES_DB=keycloak" \
  --env "POSTGRES_USER=keycloak" \
  --env "POSTGRES_PASSWORD=password" \
  postgres:9.6.1
 
docker run --detach --name kc_upgrade \
  --link kc_upgrade_db \
  --env "POSTGRES_PORT_5432_TCP_ADDR=kc_upgrade_db" \
  --publish "9999:8080" \
  jboss/keycloak-postgres:${KC_VER}

until $(curl --output /dev/null --silent --head --fail http://192.168.99.100:9999); do
  printf '.'
  sleep 5
done
 
docker cp kc_upgrade:/opt/jboss/keycloak/standalone/configuration/standalone.xml ./standalone-${KC_VER}.xml
