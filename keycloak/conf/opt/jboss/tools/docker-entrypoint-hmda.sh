#!/bin/bash

LOGIN_THEME=keycloak/themes/hmda/login/theme.properties
HMDA_REALM=import/hmda-realm.json

# Update Keycloak config files based on envvars
if [ -z ${REDIRECT_URIS+x} ]; then
    echo 'REDIRECT_URIS environment variable not set' >&2
    exit 1
else
    sed -i "s@\"{{REDIRECT_URIS}}\"@$REDIRECT_URIS@g" $HMDA_REALM
    echo "Keycloak redirect URIs set to $REDIRECT_URIS"
fi

if [ -z ${INSTITUTION_SEARCH_URI+x} ]; then
    echo 'INSTITUTION_SEARCH_URI environment variable not set' >&2
    exit 1
else
    sed -i "s@{{INSTITUTION_SEARCH_URI}}@$INSTITUTION_SEARCH_URI@g" $LOGIN_THEME
    echo "Set institutionSearchUri=$INSTITUTION_SEARCH_URI"
fi

if [ -z ${FILING_APP_URL+x} ]; then
    echo 'FILING_APP_URL environment variable not set' >&2
    exit 1
else
    sed -i "s@{{FILING_APP_URL}}@$FILING_APP_URL@g" $LOGIN_THEME
    echo "Set filingAppUrl=$FILING_APP_URL"
fi

if [ -z ${SMTP_SERVER+x} ] || [ -z ${SMTP_PORT+x} ]; then
    echo 'SMTP_SERVER and/or SMTP_PORT environment variables not set' >&2
    exit 1
else
    sed -i "s/{{SMTP_SERVER}}/$SMTP_SERVER/g" $HMDA_REALM
    echo "Set smtpServer.host=$SMTP_SERVER"

    sed -i "s/{{SMTP_PORT}}/$SMTP_PORT/g" $HMDA_REALM
    echo "Set smtpServer.port=$SMTP_PORT"
fi

if [ -z ${SUPPORT_EMAIL+x} ]; then
    echo 'SUPPORT_EMAIL environment variable not set' >&2
    exit 1
else
    sed -i "s/{{SUPPORT_EMAIL}}/$SUPPORT_EMAIL/g" $LOGIN_THEME
    echo "Set supportEmailTo=$SUPPORT_EMAIL"
fi

printf "\nEnvironment:\n"
env | sort

echo "Updated $LOGIN_THEME:"
cat $LOGIN_THEME

echo "Updated $HMDA_REALM:"
cat $HMDA_REALM

echo "Cleaning history"
rm -rf /opt/jboss/keycloak/standalone/configuration/standalone_xml_history/current/*

# Execute official entrypoint script, passing on any params
exec $(dirname ${BASH_SOURCE})/docker-entrypoint.sh "$@"

exit $?
