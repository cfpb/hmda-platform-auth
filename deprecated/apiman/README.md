# APIMan / Keycloak Docker Image

The following `Dockerfile` builds a combined APIMan / Keycloak image based on
the official APIMan image ([`apiman/on-wildfly10`](https://hub.docker.com/r/apiman/on-wildfly10/)).

In addition, this `Dockerfile` overrides the default Keycloak configuration, and
copies in customized web templates.
