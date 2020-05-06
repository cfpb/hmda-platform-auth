# HMDA Platform Auth

## Archived
Active development moved to https://github.com/cfpb/hmda-platform/tree/master/auth

## Former README
This project provides [OpenID Connect](http://openid.net/connect/)-based
authentication and authorization services for all HMDA APIs and web applications 
with identity requirements.  This currently includes the
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
Please see [the instructions in that repo](https://github.com/cfpb/hmda-platform#to-run-the-entire-platform)
for details on how to launch the system.

## Config

### Automated
The Keycloak Docker image comes with the default "master" (admin) realm, and a "hmda" realm configured 
for integrating with the oidc-client webapp.  If you want to persist changes to "hmda", edit 
`keycloak/import/hmda-realm.json`.  This file is copied in during the Docker built, and applied to 
Keycloak via its [Import/Export](https://keycloak.gitbooks.io/documentation/server_admin/topics/export-import.html)
functionality.

### Manual
When experimenting with Keycloak setting, it is easier to use the admin UI to make changes.
Below are the steps used when creating the "hmda" realm and its "hmda-api" client.

1. Login to Keycloak _master_ realm by browsing to https://192.168.99.100:8443/auth/admin/.
1. Create the _HMDA_ realm.
    1. Mouse-over _Master_ header.
    1. Select the _Add realm_ button.
    1. Add "hmda" to _Name_ field.
    1. Select the _Create_ button.
    1. On the _Login_ tab, set the following and select _Save_:
        1. **User registration:** ON
        1. **Email as username:** ON
        1. **Edit username:** OFF
        1. **Forgot password:** ON
        1. **Remember Me:** OFF
        1. **Verify email:** ON
        1. **Login with email:** ON
        1. **Require ssl:** all requests
    1. On the _Email_ tab, set following and click _Save_:
        1. **Host:** mail_dev
        1. **From:** noreply@cfpb.gov 
    1. On the _Themes_ tab, set following and select _Save_:
        1. **Login Theme:** hmda
        1. **Email Theme:** hmda
    1. On the _Tokens_ tab, set the following and select _Save_:
        1. **Login action timeout:** 60 (Minutes)
        1. **User-Initiated Action Lifespan:** 60 (Minutes)
    1. On the _Security Defenses_ / _Brute Force Detection_ tab, set the following and select _Save_:
        1. **Enabled:** ON
        1. **Permanent Lockout:** ON
1. Configure the realm's _Authentication_ settings:
    1. Select the _Authentication_ link on the left menu:
    1. On the _Flows_ tab:
        1. Select _Registration_ from the dropdown.
        1. Select the _Copy_ button.
        1. Enter "registration - hmda" in the _New Name_ field, and select _OK_.
        1. Select _Add Execution_ action for _Registration - Hmda Registration Form_.
        1. Select _Institution Validation_ for _Provider_, and select _Save_.
        1. Select _Delete_ action for _Recaptcha_.
        1. Select _REQUIRED_ for _Institution Validation_.
    1. On the _Bindings_ tab, set the following and select _Save_:
        1. Set _Registration Flow_ to  _registration - hmda_.
    1. On the _Password Policy_ tab, set these policies and select _Save_:
        1. **Expire Password:** 90
        1. **Minimum Length:** 12
        1. **Not Recently Used:** 10
        1. **Uppercase Characters:** 1 (Default)
        1. **Lowercase Characters:** 1 (Default)
        1. **Digits:** 1 (Default)
        1. **Special Characters:** 1 (Defaul)
        1. **Not Username** (No value to set here)
        1. **Hashing Iterations:** 27500 (Default)
1. Add a _hmda-api_ OpenID Connect client.
    1. Select the _Clients_ link on left menu, and select _Create_.
    1. On the _Add Client_ screen, set the following and _Save_:
        * **Client ID:**  hmda-api
    1. On the _Settings_ tab, change the following and _Save_:
        * **Standard Flow Enabled:** OFF
        * **Implicit Flow Enabled:** ON
        * **Direct Access Grant Enabled:** OFF
        * **Valid Redirect URIs:** 
            * https://192.168.99.100
            * https://192.168.99.100/oidc-callback
            * https://192.168.99.100/silent_renew.html
        * **Web Origins:** *
    1. On the _Mappers_ tab, click _Create_, set the following, and _Save_:
        * **Name:** Institutions
        * **Consent Required:** OFF
        * **Mapper Type:** User Attribute
        * **User Attribute:** institutions
        * **Token Claim Name:** institutions
        * **Claim JSON Type:** String
        * **Add to ID token:** ON
        * **Add to access token:** ON
        * **Add to userinfo:** ON
        * **Multivalued:** OFF

## Use it!
Once you've jumped through all of these setup hoops, you're ready to authenticate.

### Integrate your own app
When integrating with your own app, the following are the most important configs.
Defaults should work for the rest of the usual OIDC settings.

* **Discovery Endpoint:** https://192.168.99.100:8443/auth/realms/hmda/.well-known/openid-configuration
* **Client ID:** hmda-api

### Services
The following services are included in the Docker Compose config.

#### Keycloak
Keycloak acts as an OpenID Connect Identity Provider.  It is available at:

* https://192.168.99.100:8443/auth/

#### Auth Proxy
Secure API Gateway protecting HMDA APIs with auth requirements

* https://192.168.99.100:4443 - Auth Proxy Status
* https://192.168.99.100:4443/hmda/ - Protected HMDA Filing API

#### Email
Several of Keycloak's identity manangement workflows involve email confirmation.
In order to test this locally, we've included the [MailDev](http://danfarrelly.nyc/MailDev/)
service.  All emails sent by Keycloak can be viewed at:

* https://192.168.99.100:8443/mail/

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

