#!/usr/bin/env python3
"""
Configures Keycloak and APIMan services
"""

import json
from pprint import pprint
import requests
import time
import yaml

class OidcRestClient(object):
    """
    REST API client for Keycloak and APIMan, handling the
    OpenID Connect handshake consistently.
    """

    def __init__(self, base_url, authz_server_url, username, password, client_id):
        self.base_url = base_url

        oidc_req_data = {
            'username': username,
            'password': password,
            'grant_type': 'password',
            'client_id': client_id,
        }

        oidc_resp = requests.post(
            authz_server_url,
            data=oidc_req_data
        )
        oidc_resp.raise_for_status()

        access_token = oidc_resp.json()['access_token']
        self.authz_header = {'Authorization': 'Bearer {}'.format(access_token)}


    def request(self, method, resource, json=None):
        url = '{}/{}'.format(self.base_url, resource)
        resp = requests.request(method, url, json=json, headers=self.authz_header)

        resp.raise_for_status()

        return resp
        

def sync_keycloak(config, keycloak_client):

    realms_url = 'realms'
    realms = config['keycloak']['realms']
    realm_certs = {}

    for realm in realms:
        clients = realm.pop('clients')
        realm_id = realm['realm']
    
        realms_resp = keycloak_client.request('POST', realms_url, json=realm)
    
        realm_url = '{}/{}'.format(realms_url, realm_id)
        realm_resp = keycloak_client.request('GET', realm_url)
        realm_cert = realm_resp.json()['certificate']
    
        # Map certs to their realm.  Needed later by APIMan
        realm_certs[realm_id] = realm_cert

        print('Added Keycloak realm "{}"'.format(realm_id))
    
        for client in clients:
            mappers = client.pop('protocolMappers')
            client_id = client['clientId']
            clients_url = '{}/clients'.format(realm_url, realm_id)
            client_resp = keycloak_client.request('POST', clients_url, json=client)

            # Get the client GUID off the URL of the newly created client
            client_guid = client_resp.headers['Location'].split('/')[-1]
            client_url = '{}/{}'.format(clients_url, client_guid)

            print('Added Keycloak client "{}" ({}) to realm "{}"'.format(client_id, client_guid, realm_id))

            for mapper in mappers:
                mapper_id = mapper['name']
                mappers_url = '{}/protocol-mappers/models'.format(client_url)
                mapper_resp = keycloak_client.request('POST', mappers_url, json=mapper)

                print('Added Keycloak protocol mapper "{}" to client "{}"'.format(mapper_id, client_id))

    return realm_certs


def sync_gateways(gateways, apiman_client):
    for gateway in gateways:
        
        gateway_id = gateway.pop('id')
        gateway.pop('name')
    
        gateway_cfg_str = json.dumps(gateway['configuration'])
        gateway['configuration'] = gateway_cfg_str
    
        gateway_url = 'gateways/{}'.format(gateway_id)
        gateway_resp = apiman_client.request('PUT', gateway_url, json=gateway)
    
        print('Updated APIMan gateway "{}"'.format(gateway_id))


def sync_plugins(plugins, apiman_client):
    for plugin in plugins:
        plugin_id = plugin['artifactId']
        plugin_resp = apiman_client.request('POST', 'plugins', json=plugin)

        print('Added APIMan plugin "{}"'.format(plugin))


def sync_orgs(orgs, apiman_client, realm_certs):
    orgs_url = 'organizations'

    for org in orgs:
        org_id = org['name']
        apis_url = '{}/{}/apis'.format(orgs_url, org_id)
        apis = org.pop('apis')

        org_resp = apiman_client.request('POST', orgs_url, json=org)

        print('Added APIMan Org "{}"'.format(org_id))
 
        for api in apis:
            api_id = api['name']
            versions_url = '{}/{}/versions'.format(apis_url, api_id)
            versions = api.pop('versions')

            api_resp = apiman_client.request('POST', apis_url, json=api)

            print('Added APIMan API "{}" to "{}"'.format(api_id, org_id))

            for version in versions:
                version_id = version['version']
                policies_url = '{}/{}/policies'.format(versions_url, version_id)
                policies = version.pop('policies')

                version_resp = apiman_client.request('POST', versions_url, json=version)

                print('Added APIMan version "{}" to API "{}:{}"'.format(version_id, org_id, api_id))

                for policy in policies:
                    policy_def = policy['definitionId']
                    pol_cfg = policy['configuration']
                    
                    if(policy_def == 'keycloak-oauth-policy'):
                        # Get realm name from tail of realm url
                        realm_name = pol_cfg['realm'].split('/')[-1]

                        # Get the Keycloak cert for a given realm
                        pol_cfg['realmCertificateString'] = realm_certs[realm_name]

                    # Flatten `configuration` into a json string
                    policy['configuration'] = json.dumps(pol_cfg)

                    pol_resp = apiman_client.request('POST', policies_url, json=policy)

                    print('Added APIMan policy "{}" to {}:{}:{}'.format(
                        policy_def, org_id, api_id, version_id
                    ))

                # Publish API Version
                action = {
                    'type': 'publishAPI',
                    'entityId': api_id, 
                    'entityVersion': version_id,
                    'organizationId': org_id
                }

                pub_resp = apiman_client.request('POST', 'actions', json=action)

                print('Published API {}:{}:{}'.format(org_id, api_id, version_id))


# Sync apiman data
def sync_apiman(config, apiman_client, realm_certs):
    apiman = config['apiman']

    sync_gateways(apiman['gateways'], apiman_client)
    sync_plugins(apiman['plugins'], apiman_client)
    sync_orgs(apiman['organizations'], apiman_client, realm_certs)

def is_up(service_name, url):
    """
    Waits for a given URL to respond with an acceptable
    HTTP status code(s)
    """

    from requests.exceptions import ConnectionError, HTTPError
    from json.decoder import JSONDecodeError

    # Wait for APIMan to be available
    while True:
        try:
            is_up_resp = requests.get(url)
            is_up_resp.raise_for_status()
            print('{} is up at {}'.format(service_name, url))
            break
        #except NewConnectionError as nce:
        except (ConnectionError, HTTPError, JSONDecodeError) as ce:
            print('Waiting for {} at {}...'.format(service_name, url))
            #print(ce)
            time.sleep(5)

def main():

    #FIXME: Pass these in a params
    username = 'admin'
    password = 'admin123!'
    root_url = 'http://192.168.99.100'
    
    # Setup base URLs
    keycloak_base_url = '{}/auth'.format(root_url)
    keycloak_api_url = '{}/admin'.format(keycloak_base_url)
    apiman_api_url = '{}/apiman'.format(root_url)

    # Make sure Keycloak and APIMan are fully up first
    is_up('APIMan', apiman_api_url)
    is_up('Keycloak', '{}/realms/master'.format(keycloak_base_url))

    keycloak_client = OidcRestClient(
        keycloak_api_url,
        '{}/realms/master/protocol/openid-connect/token'.format(keycloak_base_url),
        username,
        password,
        'admin-cli'
    )
    
    apiman_client = OidcRestClient(
        apiman_api_url,
        '{}/realms/apiman/protocol/openid-connect/token'.format(keycloak_base_url),
        username,
        password,
        'apiman'
    )

    # Read in config.yaml
    config = None
    
    with open('config.yaml') as config_file:
        config = yaml.load(config_file)

    # Configure Keycloak and APIMan based on config.yaml
    realm_certs = sync_keycloak(config, keycloak_client)
    sync_apiman(config, apiman_client, realm_certs)

    #client_resp = keycloak_client.request('GET', 'realms/hmda/clients/')
    #pprint(client_resp.json())

if __name__ == "__main__":
    main()
