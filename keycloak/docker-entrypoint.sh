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
    echo "INSTITUTION_SEARCH_URI=$INSTITUTION_SEARCH_URI"
    sed -i "s@{{INSTITUTION_SEARCH_URI}}@$INSTITUTION_SEARCH_URI@g" keycloak/themes/hmda/login/theme.properties
    echo "Set institutionSearchUri=$INSTITUTION_SEARCH_URI"
fi

if [ -z ${HOME_PAGE_URI+x} ]; then
    echo 'HOME_PAGE_URI environment variable not set' >&2
    exit 1
else
    echo "HOME_PAGE_URI=$HOME_PAGE_URI"
    sed -i "s@{{HOME_PAGE_URI}}@$HOME_PAGE_URI@g" keycloak/themes/hmda/login/theme.properties
    echo "Set homePageUri=$HOME_PAGE_URI"
fi

if [ -z ${SUPPORT_EMAIL+x} ]; then
    echo 'SUPPORT_EMAIL environment variable not set' >&2
    exit 1
else
    echo "SUPPORT_EMAIL=$SUPPORT_EMAIL"
    sed -i "s/{{SUPPORT_EMAIL}}/$SUPPORT_EMAIL/g" keycloak/themes/hmda/login/theme.properties
    echo "Set supportEmailTo=$SUPPORT_EMAIL"
fi

export HOSTNAME_IP=$(hostname -i)
export HOSTNAME_IP_ALL=$(hostname --all-ip-addresses)
echo "hostname -i returned: $HOSTNAME_IP, -I returned: $HOSTNAME_IP_ALL"

echo 'Keycloak "login" theme.properties updated:'
cat keycloak/themes/hmda/login/theme.properties

exec /opt/jboss/keycloak/bin/standalone.sh \
      -Dkeycloak.migration.action=import \
      -Dkeycloak.migration.provider=dir \
      -Dkeycloak.migration.dir=/opt/jboss/import/ \
      -Dkeycloak.migration.strategy=OVERWRITE_EXISTING \
      -Dkeycloak.migration.usersExportStrategy=SKIP \
      -Djboss.jgroups.stack=udp \
      -Djboss.jgroups.udp.port=5520 \
      -Djboss.jgroups.udp.multicast.port=4568 \
      -Djboss.jgroups.udp.fd.port=5420 \
      -Djboss.bind.address.private=$HOSTNAME_IP \
      -b 0.0.0.0 -bmanagement 0.0.0.0 --server-config standalone-ha.xml

exit $?
