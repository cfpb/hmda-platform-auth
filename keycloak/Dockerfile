FROM jboss/keycloak-postgres:3.2.1.Final

ENV MAVEN_VER=3.5.2
ENV MAVEN_DIST=apache-maven-$MAVEN_VER
ENV MAVEN_FILE=$MAVEN_DIST-bin.tar.gz
ENV PATH=$PATH:/tmp/$MAVEN_DIST/bin
ENV KC_SPI_SRC=providers
ENV KC_SPI_DEST=/usr/src/keycloak
ENV KC_LIB_VER=3.2.1.Final

# Install Maven (YUM version is too old)
RUN curl -s -o /tmp/${MAVEN_FILE} http://www-us.apache.org/dist/maven/maven-3/${MAVEN_VER}/binaries/${MAVEN_FILE} && \
    cd /tmp && \
    tar -xzf ${MAVEN_FILE} && \
    cd ${MAVEN_DIST} && \
    mvn --version 

# Overwrite the default Keycloak startup script
COPY docker-entrypoint.sh /opt/jboss/

# Copy JBoss Wildfly-based config file
COPY standalone.xml /opt/jboss/keycloak/standalone/configuration

# Copy realms and users for import at startup
COPY import /opt/jboss/import

# Copy all custom web and email themes
COPY themes/hmda /opt/jboss/keycloak/themes/hmda

# Copy custom authenticator provider source code
COPY ${KC_SPI_SRC} ${KC_SPI_DEST}/${KC_SPI_SRC}

# Perform root user actions
USER root

# FIXME: Replace this with new COPY/ADD owner options when that feature become available
#   SEE: https://github.com/docker/docker/pull/27303 
RUN chmod -R a+w ${KC_SPI_DEST} && chown -R jboss:jboss /opt/jboss

# Get the latest yum packages, and cleanup packages from parent images
RUN yum-config-manager --enable cr && \
	yum -y erase augeas augeas-libs && \
	yum -y update && \
	yum -y clean all

USER jboss

# Build the Keycloak authenticator SPI
# NOTE: If we develop more SPIs, we may want to iterate over a directory structure, building as we go.
RUN echo 'Keycloak SPI build starting...' && \
    cd ${KC_SPI_DEST}/${KC_SPI_SRC}/authenticator/hmda && \
    mvn --quiet clean install && \
    mkdir /opt/jboss/keycloak/providers && \
    cp target/keycloak-authenticator-hmda-${KC_LIB_VER}.jar /opt/jboss/keycloak/providers && \
    rm -rf /opt/jboss/.m2 && \
    echo 'Keycloak SPIs build successful!'

EXPOSE 8080
