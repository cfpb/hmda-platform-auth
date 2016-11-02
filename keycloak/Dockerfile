FROM jboss/keycloak:2.3.0.Final

ENV KEYCLOAK_LOGLEVEL TRACE

# Generate TLS keypair for Keycloak over HTTPS
RUN keytool -genkey -noprompt \
    -alias keycloak \
    -keyalg RSA \
    -dname "CN=localhost, OU=Test, L=Testtown, ST=CA, C=US" \
    -keystore keycloak.jks \
    -storepass password \
    -keypass password && \
    mv keycloak.jks /opt/jboss/keycloak/standalone/configuration/

# Copy JBoss Wildfly-based config file
COPY standalone.xml /opt/jboss/keycloak/standalone/configuration/

# Copy realms and users for import at startup
COPY import /opt/jboss/import

# Copy all custom web and email themes
COPY themes/hmda /opt/jboss/keycloak/themes/hmda

EXPOSE 8443
