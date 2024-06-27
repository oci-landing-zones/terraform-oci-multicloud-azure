import argparse
import os
import requests
import json


def read_user_mapping_attributes_json(filename):
    f = open(os.path.join(os.getcwd(), filename), 'r')
    user_mapping_attribute = f.read()
    return json.loads(user_mapping_attribute)


# https://learn.microsoft.com/en-us/graph/api/synchronization-synchronizationschema-get
def fetch_job_schema(service_principal_id, job_id, headers):
    job_schema_url = "https://graph.microsoft.com/v1.0/servicePrincipals/{}/synchronization/jobs/{}/schema".format(
        service_principal_id, job_id)
    try:
        get_response = requests.get(job_schema_url, headers=headers)
        get_response.raise_for_status()
    except requests.exceptions.HTTPError as e:
        print(e.args[0])
    job_schema_json = get_response.json()
    return job_schema_json



# https://learn.microsoft.com/en-us/graph/api/synchronization-synchronizationschema-update
def update_job_schema(service_principal_id, job_id, headers, payload):
    job_schema_url = "https://graph.microsoft.com/v1.0/servicePrincipals/{}/synchronization/jobs/{}/schema".format(
        service_principal_id, job_id)
    try:
        update_response = requests.put(job_schema_url, json=payload, headers=headers)
        update_response.raise_for_status()
        if update_response.status_code == 204:
            print('schema updated successfully')
        else:
            print('schema updated failed with code: ', update_response.status_code, ' \nerror body: ',
                  update_response.content)
    except requests.exceptions.HTTPError as e:
        print(e.args[0])


def msgraph_api_access_token():
    az_token_key = 'AZ_TOKEN'
    try: 
        os.environ[az_token_key] 
    except KeyError:
        raise Exception(f"env var ", az_token_key, 
                        " is not set. execute to set 'export AZ_TOKEN=$(az account get-access-token --resource-type ms-graph | jq -r .accessToken)' ")
    return os.environ.get(az_token_key)
    
        

def azad_sync_job_schema_modify(service_principal_id, provision_job_id):
   
    r_headers = {'Authorization': 'Bearer ' + msgraph_api_access_token(), 'Accept': 'application/json'}

    # fetch existing job schema
    job_schema_json = fetch_job_schema(service_principal_id=service_principal_id, job_id=provision_job_id,
                                       headers=r_headers)

    # add new attributes to existing job schema 
    sra = job_schema_json['synchronizationRules']
    for sr in sra:
        if sr['name'] == 'USERGROUP_OUTBOUND_USERGROUP' and sr['sourceDirectoryName'] == 'Microsoft Entra ID':
            objMaps = sr['objectMappings']
            for om in objMaps:
                if om['name'] == 'Provision Microsoft Entra ID Users' and om['sourceObjectName'] == 'User':
                    # read federated_user attribute
                    federated_user_attr = read_user_mapping_attributes_json(
                        filename='scripts/federated_user_mapping_attribute.json')
                    om['attributeMappings'].append(federated_user_attr)

                    # read bypass notif attribute
                    bypass_notification_attr = read_user_mapping_attributes_json(
                        'scripts/bypass_notification_mapping_attribute.json')
                    om['attributeMappings'].append(bypass_notification_attr)

    update_job_schema(service_principal_id, job_id=provision_job_id, headers=r_headers, payload=job_schema_json)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-sp', '--service_principal_id', help='Service principal id', required=True)
    parser.add_argument('-pj', '--provision_job_id', help='SSO identity Provision job Id', required=True)
    
    args = parser.parse_args()
    
    azad_sync_job_schema_modify(args.service_principal_id, args.provision_job_id)
