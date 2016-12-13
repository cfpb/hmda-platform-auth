#!/bin/bash

if [ -z ${REDIRECT_URIS+x} ]; then
  echo 'REDIRECT_URIS environment variable not set' >&2
  exit 1
else
  sed -i "s@{{REDIRECT_URIS}}@$REDIRECT_URIS@g" import/hmda-realm.json
  echo "Keycloak redirect URIs set to $REDIRECT_URIS"
fi

if [ ! -z ${KEYCLOAK_USER+x} ] && [ ! -z ${KEYCLOAK_PASSWORD+x} ]; then
    keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
fi

if [ -z ${INSTITUTION_SEARCH_URI+x} ]; then
    echo 'INSTITUTION_SEARCH_URI environment variable not set' >&2
    exit 1
else
    echo "INSTITUTION_SEARCH_URI=$INSTITUTION_SUPPORT_URI"
    sed -i "s@{{INSTITUTION_SEARCH_URI}}@$INSTITUTION_SEARCH_URI@g" keycloak/themes/hmda/login/theme.properties
    echo "Set institutionSearchUri=$INSTITUTION_SEARCH_URI"
fi

if [ -z ${SUPPORT_EMAIL+x} ]; then
    echo 'SUPPORT_EMAIL environment variable not set' >&2
    exit 1
else
    echo "SUPPORT_EMAIL=$SUPPORT_EMAIL"
    sed -i "s/{{SUPPORT_EMAIL}}/$SUPPORT_EMAIL/g" keycloak/themes/hmda/login/theme.properties
    echo "Set supportEmail=$SUPPORT_EMAIL"
fi

echo 'Keycloak "login" theme.properties updated:'
cat keycloak/themes/hmda/login/theme.properties

exec /opt/jboss/keycloak/bin/standalone.sh $@
exit $?
