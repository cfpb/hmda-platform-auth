# HMDA Platform Auth

This is a prototype for providing [OpenID Connect](http://openid.net/connect/)-based
authentication and authorization services for all HMDA APIs and web applications 
with identity requirements.  This is currently implemented to support the 
[`hmda-platform`](https://github.com/cfpb/hmda-platform) and 
[`hmda-platform-ui`](https://github.com/cfpb/hmda-platform-ui) projects,
though may support more in the future.

## Technologies

* [Keycloak](http://www.keycloak.org/) - Open-source identity management, with full OpenID Connect support.
* [mod_auth_openidc](https://github.com/pingidentity/mod_auth_openidc) - Open-source OpenID Connect authentication and authorization proxy.

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
docker-compose rm -vf auth_proxy keycloak && docker-compose build --no-cache auth_proxy keycloak && docker-compose up
```

This will guarantee that old containers (and their data) are removed, and new ones are build from scratch.

## Config it!
This project is not fully automated yet.  In order to integrate with these service, you'll need to do a bit of manual configuration.

1. Login to Keycloak _master_ realm by browsing to https://192.168.99.100:8443/auth/admin/.
1. Create the _HMDA_ realm.
    1. Mouse-over _Master_ header.
    1. Click _Add realm_ button.
    1. Add "hmda" to _Name_ field.
    1. Click _Create_ button.
    1. On the _Email_ tab, fill in the following fields, and click _Save_:
        1. Host: mail_dev
        1. From: hmda-support@keycloak.local
1. Add a _hmda-api_ OpenID Connect client.
    1. Follow _Clients_ link on left menu, and click _Create_.
    1. Set _Client ID_ to hmda-api, and click _Save_.
    1. On the _Settings_ tab, change the following options, and click _Save_:
        1. Standard Flow Enabled: OFF
        1. Implicit Flow Enabled: ON
        1. Direct Access Grant Enabled: OFF
        1. Valid Redirect URIs: http://192.168.99.100:7070
            * **NOTE:** This is the URI for the test webapp.  You will need to add additional for other apps.
        1. Web Origins: *
    1. On the _Mappers_ tab, click _Create_, fill out the following, and _Save_.
        1. Name: Institutions
        1. Mapper Type: User Attribute
        1. User Attribute: institutions
        1. Token Claim Name: institutions
        1. Claim JSON Type: String
        1. Add to access token: ON
1. Add Users
    1. Follow _Users_ link on left menu.
    1. Click _Add user_.
    1. Fill in these fields, and click _Save_:
        1. Username, Email, First Name, Last Name
        1. User Enabled: ON
        1. Email Verified: ON
    1. On the _Attributes_ tab, filling in the following, and click _Add_ and _Save_.
        1. Key: institutions
        1. Value: 1,2
    1. On the _Credentials_ tab:
        1. Fill in _New Password_ and _Password Confirmation_.
        1. Set _Temporary_ to _OFF_
        1. Click big red _Reset Password_, and then _Change password_ buttons.
        

## Use it!
Once you've jumped through all of these setup hoops, you're ready to authenticate.

### Integrate your own app
When integrating with your own app, the following are the most important configs.  Defaults should work for the rest of the usual OIDC settings.

* **Discovery Endpoint:** https://192.168.99.100:8443/auth/realms/hmda/.well-known/openid-configuration
* **Client ID:** hmda-api

### Services

The following services are included in the Docker Compose config.

#### Keycloak
Keycloak acts as an OpenID Connect Identity Provider.  It is available at:

* https://192.168.99.100:8443/auth/

#### Echo API
This is a simple REST API that _echos_ back the request it received, including all headers added by the Auth Proxy.  This can be extremely useful while debugging OIDC settings.

* http://192.168.99.100:5000 (directly)
* https://192.168.99.100 (through the Auth Proxy)

#### OpenId Connect Demo Webapp
This is a simple OIDC test webapp used for testing purposes.  It authenticates with Keycloak, and makes CORS API calls through the Auth Proxy to both the Echo API and HMDA Platform API.

* http://192.168.99.100:7070 

#### Email
Several of Keycloak's identity manangement workflows involve email confirmation.  In order to test this locally, we've included the [MailDev](http://danfarrelly.nyc/MailDev/) service.  All emails sent by Keycloak can be viewed at:

* http://192.168.99.100:1080/

### Self-signed Certs
**WARNING:** The Keycloak and Auth Proxy services both required to run over HTTPS.  However, this dev setup uses self-signed certificates, which can result in unexpected behavior when the services first start.  In order to get around this in dev, you should browse to each the following services and accept the untrusted certs.

* https://192.168.99.100 (Auth Proxy)
* https://192.168.99.100:8443 (Keycloak)

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

