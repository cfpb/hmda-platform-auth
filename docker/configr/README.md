# `configr` Docker Image

This is a custom Python-based tool used for initializing
Keycloak and APIMan based on hmda-platform's needs.  This is
necessary because both Keycloak's and APIMan's built-in
config-on-startup are not-so-great in their own special way.

In addition, we're using APIMan's Keycloak plugin, which 
requires exchanging certificates generated at Keycloak 
initialization, which makes using a static configuration for
APIMan infeasable.

## Known Issues

* `config` can only be executed once.  If you attempt to apply
    changes to a configured system, it will fail.  If we decided
    to keep this as our configuration tool, we'll have to fix this.

* Docker Compose doesn't seem to be smart enough to rebuild this
    image when you change the underlying Python script or config file,
    so you must force it.  The following will force a rebuild of both
    `configr` and `apiman` services, which is the general workflow when
    tweaking the script.

    ```
    docker-compose rm -vfa configr apiman && docker-compose build --no-cache configr && docker-compose up
    ```
