#!/bin/bash

LOGIN_THEME=keycloak/themes/hmda/login/theme.properties
HMDA_REALM=import/hmda-realm.json

# Update Keycloak config files based on envvars
if [ -z ${REDIRECT_URIS+x} ]; then
  echo 'REDIRECT_URIS environment variable not set' >&2
  exit 1
else
  sed -i "s@\"{{REDIRECT_URIS}}\"@$REDIRECT_URIS@g" import/hmda-realm.json
  echo "Keycloak redirect URIs set to $REDIRECT_URIS"
fi

if [ ! -z ${KEYCLOAK_USER+x} ] && [ ! -z ${KEYCLOAK_PASSWORD+x} ]; then
    keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
    echo "Keycloak admin user \"$KEYCLOAK_USER\" created."
fi

if [ -z ${INSTITUTION_SEARCH_URI+x} ]; then
    echo 'INSTITUTION_SEARCH_URI environment variable not set' >&2
    exit 1
else
    sed -i "s@{{INSTITUTION_SEARCH_URI}}@$INSTITUTION_SEARCH_URI@g" $LOGIN_THEME
    echo "Set institutionSearchUri=$INSTITUTION_SEARCH_URI"
fi

if [ -z ${HOME_PAGE_URI+x} ]; then
    echo 'HOME_PAGE_URI environment variable not set' >&2
    exit 1
else
    sed -i "s@{{HOME_PAGE_URI}}@$HOME_PAGE_URI@g" keycloak/themes/hmda/login/theme.properties
    echo "Set homePageUri=$HOME_PAGE_URI"
fi

if [ -z ${SMTP_SERVER+x} ] || [ -z ${SMTP_PORT+x} ]; then
    echo 'SMTP_SERVER and/or SMTP_PORT environment variables not set' >&2
    exit 1
else
    sed -i "s/{{SMTP_SERVER}}/$SMTP_SERVER/g" /opt/jboss/import/hmda-realm.json
    echo "Set smtpServer.host=$SMTP_SERVER"

    sed -i "s/{{SMTP_PORT}}/$SMTP_PORT/g" /opt/jboss/import/hmda-realm.json
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

exec /opt/jboss/keycloak/bin/standalone.sh \
      -Dkeycloak.migration.action=import \
      -Dkeycloak.migration.provider=dir \
      -Dkeycloak.migration.dir=/opt/jboss/import/ \
      -Dkeycloak.migration.strategy=OVERWRITE_EXISTING \
      -Dkeycloak.migration.usersExportStrategy=SKIP \
      -b 0.0.0.0 \
      --server-config standalone.xml

exit $?
