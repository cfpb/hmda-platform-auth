#!/bin/bash

if [ $KEYCLOAK_USER ] && [ $KEYCLOAK_PASSWORD ]; then
    keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
fi

if [ $INSTITUTION_SEARCH_URI ]; then
    sed -i "s@{{INSTITUTION_SEARCH_URI}}@$INSTITUTION_SEARCH_URI@g" keycloak/themes/hmda/login/theme.properties
    echo 'Keycloak "login" theme.properties updated:'
    cat keycloak/themes/hmda/login/theme.properties
else
    echo 'INSTITUTION_SEARCH_URI environmental variable not set' >&2
    exit 1
fi


exec /opt/jboss/keycloak/bin/standalone.sh $@
exit $?
