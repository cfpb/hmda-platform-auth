# HMDA Platform Auth

This is a prototype for providing [OpenID Connect](http://openid.net/connect/)-based
authentication and authorization services for all HMDA APIs and web applications 
with identity requirements.  This is currently implemented to support the 
[`hmda-platform`](https://github.com/cfpb/hmda-platform) and 
[`hmda-platform-ui`](https://github.com/cfpb/hmda-platform-ui) projects,
though may support more in the future.

## Technologies

* [Keycloak](http://www.keycloak.org/) - Open-source identity management, with full OpenID Connect support.
* [APIMan](http://www.apiman.io/latest/) - Open-source API management, abstracting OpenID Connect details from underlying APIs.
* [Python 3](https://docs.python.org/3/) - Used for provisioning Keycloak and APIMan instances.

## Dependencies

This project has been fully Docker-ized.  Docker is all you need to launch the full stack!

* [Docker](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)

## Installation

This project is intended to be run from [`hmda-platform`](https://github.com/cfpb/hmda-platform)'s
Docker Compose setup, configured in [`hmda-platform/docker-compose.yml`](https://github.com/cfpb/hmda-platform/blob/master/docker-compose.yml).
Please see the instructions in that repo for details on how to launch the system.

## Run it!

### First Time

When you are launching this stack from a clean slate, all you need is a simple:

```
docker-compose up
```

### Re-running

If you're making changes, and you'd like to rebuild and launch the full stack, 
the safest way to do so is with:

```
docker-compose rm -vfa configr apiman && docker-compose build --no-cache configr apiman && docker-compose u
```

This will guarantee that old containers (and their data) are removed, and new ones are build from scratch.

## Known issues

The `configr` provisioning tool currently only works from a clean install.  Subsequent runs of `configr` against fully provisioned
systems will fail.

## Getting help

If you have questions, concerns, bug reports, etc, please file an issue in this repository's Issue Tracker.

## Getting involved

[CONTRIBUTING](CONTRIBUTING.md)

## Open source licensing info
1. [TERMS](TERMS.md)
2. [LICENSE](LICENSE)
3. [CFPB Source Code Policy](https://github.com/cfpb/source-code-policy/)

## Credits and references

1. Related projects
  - https://github.com/cfpb/hmda-platform
  - https://github.com/cfpb/hmda-platform-ui 

