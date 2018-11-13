# Keycloak

Keycloak is a open-source Java-based identity management platform, specializing in
authentication protocols such as SAML and OpenID Connect.


# Project Layout

This `keycloak` subdirectory of the `hmda-platform-auth` project contains everything needed to build
our Keycloak customizations, and run Keycloak itself.

## `conf`
All configuration files and automation scripts need for launching the Keycloak container.
This includes both server-level and HMDA realm-specific data.

## `providers`
Custom [Keycloak Service Provider Interface (SPI)](https://keycloak.gitbooks.io/server-developer-guide/content/v/2.4/topics/providers.html)i
implementations.

## `themes`
Custom [Keycloak Themes](https://keycloak.gitbooks.io/server-developer-guide/content/v/2.4/topics/themes.html)
that override Keycloak's default user interface.


# Running Keycloak

The easiest way to run Keycloak is via the Docker Compose setup in the `hmda-platform` project.
See [To run the entire platform](https://github.com/cfpb/hmda-platform#to-run-the-entire-platform) for details.


# Upgrading Keycloak

Keycloak releases new versions quite frequently.  Since we're using a Docker-based install, the upgrade itself
is quite simple.  Just increment the version number in `Dockerfile`, and rebuild using the Docker Compose setup
in `hmda-platform`.

The tricky bit is knowing what exactly is included in a given upgrade.  Frequently an upgrade includes changes
to configuration files, Java-based server APIs, and/or their themes.  Any of these types of changes has the
potential to break the build, or even worse, cause runtime issues that are difficult to debug.

## Resources

One way to know what's coming in a given release is to follow Keycloak's various web resources.

* http://blog.keycloak.org/
* https://github.com/keycloak/keycloak/releases
* https://issues.jboss.org/projects/KEYCLOAK
* https://hub.docker.com/r/jboss/keycloak-postgres/

## Diffing Versions

The only way to _really_ know the difference between two Keycloak instances is by launching 
the two versions of the image, and doing a `diff` against their contents.  This works especially
well for text-based files such as config files and templates, which is where most of the breaking
changes occur.

This repo includes a `image-diff.sh` tool, which generates a [unified diff](https://en.wikipedia.org/wiki/Diff_utility#Unified_format)
of a given directory with each container.  It works as follows:

```bash
./image-diff.sh <image_name> <version_1> <version_2> <diff_src_dir> <diff_dest_dir> [docker_run_opts] [container_up_url]
```

In order to use this tool on the `jboss/keycloak-postgres` image, you also have to start up a Postgres container
for it to connect to.  The following is the full set of commands for diffing this image.

```bash
docker run --detach --name kc_upgrade_db \
  --env "POSTGRES_DB=keycloak" \
  --env "POSTGRES_USER=keycloak" \
  --env "POSTGRES_PASSWORD=password" \
  postgres:9.6.1 && \
./image-diff.sh \
  "jboss/keycloak-postgres" \
  "3.2.1.Final" \
  "3.4.0.Final" \
  "/opt/jboss" \
  "/tmp/keycloak" \
  "--link kc_upgrade_db --env POSTGRES_PORT_5432_TCP_ADDR=kc_upgrade_db --publish 9999:8080" \
  "http://192.168.99.100:9999" && \
docker stop -t 0 kc_upgrade_db && \
docker rm -vf kc_upgrade_db
```

You can now view the diff at `/tmp/keycloak/images.diff`.

## Rebuilding Realm `import` files
New versions of Keycloak frequently add new features or tweak default settings
that result in changes to the realm config files (`keycloak/import`) in this repo.
In order to make sure these new features are included, follow these steps to 
rebuild the import config file:

1. Start the newly upgraded Keycloak container.
1. Login to the admin app.
1. Delete the current "hmda" realm by clicking the trash can icon.
1. Follow the steps in the _Manual_ config on the main README.md.
1. Confirm all auth related features of the hmda-platform stack work.
1. Select _Export_ from the left menu.
1. Set the following on the _Partial Export_ screen
    1. **Export groups and roles:** ON
    1. **Export clients:**: ON
1. Click _Export_, saving the file over the existing
    `keycloak/import/hmda-realm.json` file.
1. Re-add the following templatized JSON attribute values:

    1. OIDC redirect URIs

        **Note:** There are multiple `redirectUris` attributes
        in the file.  Make sure you only set `{{REDIRECT_URIS}}`
        in the `hmda-api` client section.

        ```json
            {
              "id": "4638801f-5b2d-4628-984d-d79fbac87f3c",
              "clientId": "hmda-api",
              "surrogateAuthRequired": false,
              "enabled": true,
              "clientAuthenticatorType": "client-secret",
              "secret": "**********",
              "redirectUris": "{{REDIRECT_URIS}}",
              "webOrigins": [
                "*"
              ],
            ...
        ```

    1. SMTP Settings

        ```json
          "smtpServer" : {
            "host" : "{{SMTP_SERVER}}",
            "port" : "{{SMTP_PORT}}",
            "from" : "noreply@cfpb.gov",
            "auth": "",
            "ssl": ""
          },
        ```

