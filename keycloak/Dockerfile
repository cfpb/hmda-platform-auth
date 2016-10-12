FROM jboss/keycloak:2.2.1.Final

# Generate TLS keypair for Keycloak over HTTPS
RUN keytool -genkey -noprompt \
    -alias keycloak \
    -keyalg RSA \
    -dname "CN=localhost, OU=Test, L=Testtown, ST=CA, C=US" \
    -keystore keycloak.jks \
    -storepass password \
    -keypass password && \
    mv keycloak.jks /opt/jboss/keycloak/standalone/configuration/

COPY standalone.xml /opt/jboss/keycloak/standalone/configuration/

EXPOSE 8443
