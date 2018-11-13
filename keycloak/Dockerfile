FROM jboss/keycloak:4.5.0.Final

# REMINDER: Always update and rebuild "provider" libs when upgrading docker image
ENV KC_LIB_VER=4.5.0.Final

# Parent defaults to:
# WORKDIR /opt/jboss

ENV PATH=$PATH:/opt/jboss/keycloak/bin
# Add config files, scripts, etc. 
COPY conf /

# Copy all custom web and email themes
COPY themes/hmda keycloak/themes/hmda

# Copy custom authenticator provider source code
COPY providers/deployments/*-4.5.0.Final.jar keycloak/standalone/deployments

# Customize Wildfly config via JBoss CLI tool
RUN jboss-cli.sh --file=tools/cli/hmda.cli && cat keycloak/standalone/configuration/standalone.xml

# Perform root user actions, then switch back to jboss user
USER root
# FIXME: Replace with COPY/ADD owner options when feature become available
RUN chown -R jboss:jboss /opt/jboss && chmod u+x /opt/jboss/tools/docker-entrypoint.sh
USER jboss

EXPOSE 8080

ENTRYPOINT [ "./tools/docker-entrypoint-hmda.sh" ]

# WARN: Keycloak's docker-entrypoint.sh only checks for -c, not --server-config
CMD [ "-Dkeycloak.migration.action=import", \
      "-Dkeycloak.migration.provider=dir", \
      "-Dkeycloak.migration.dir=/opt/jboss/import/", \
      "-Dkeycloak.migration.strategy=IGNORE_EXISTING", \
      "-b", "0.0.0.0", \
      "-c", "standalone.xml" ]
