#!/bin/bash

if [ -z ${REDIRECT_URIS+x} ]; then
  echo 'REDIRECT_URIS environment variable not set' >&2
  exit 1
else
  sed -i "s@{{REDIRECT_URIS}}@$REDIRECT_URIS@g" import/hmda-realm.json
  echo "Keycloak redirect uris set to $REDIRECT_URIS"
fi

if [ $KEYCLOAK_USER ] && [ $KEYCLOAK_PASSWORD ]; then
    keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
fi

if [ $INSTITUTION_SEARCH_URI ]; then
    sed -i "s@{{INSTITUTION_SEARCH_URI}}@$INSTITUTION_SEARCH_URI@g" keycloak/themes/hmda/login/theme.properties
    echo 'Keycloak "login" theme.properties updated:'
    cat keycloak/themes/hmda/login/theme.properties
else
    echo 'INSTITUTION_SEARCH_URI environment variable not set' >&2
    exit 1
fi

exec /opt/jboss/keycloak/bin/standalone.sh $@
exit $?
