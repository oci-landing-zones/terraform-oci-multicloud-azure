import argparse
import logging
import os
import urllib.request
import urllib.error
import json
from datetime import datetime, timedelta

import oci
from src.common import get_signer

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(message)s")


def verify_oci_billing_usage_metrics(resource_ocid: str, config_file_profile: str, tenant_id: str):
    cost = get_oci_billing_usage_metrics(resource_ocid=resource_ocid, config_file_profile=config_file_profile,
                                         query_type="COST", tenant_id=tenant_id)
    if len(cost) > 0:
        logging.info(f"OCI Cost metrics is visible and Validation is Passed!")
    usage = get_oci_billing_usage_metrics(resource_ocid=resource_ocid, config_file_profile=config_file_profile,
                                          query_type="USAGE", tenant_id=tenant_id)
    if len(usage) > 0:
        logging.info(f"OCI Usage metrics is visible and Validation is Passed!")


def get_oci_billing_usage_metrics(resource_ocid: str, config_file_profile: str, query_type: str, tenant_id: str):
    auth = get_signer(config_file_profile=config_file_profile)
    config = oci.config.from_file(profile_name=config_file_profile)
    # Initialize service client with default config file
    usage_api_client = oci.usage_api.UsageapiClient(config, signer=auth, timeout=120,
                                                    retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)
    now = datetime.now().utcnow().strftime("%Y-%m-%dT%000:%000:%000Z")
    start_time = (datetime.now().utcnow() - timedelta(days=20)).strftime("%Y-%m-%dT%000:%000:%000Z")
    try:
        # Send the request to service, some parameters are not required, see API
        # doc for more info
        request_summarized_usages_response = usage_api_client.request_summarized_usages(
            request_summarized_usages_details=oci.usage_api.models.RequestSummarizedUsagesDetails(
                tenant_id=tenant_id,
                time_usage_started=start_time,
                time_usage_ended=now,
                granularity="DAILY",
                query_type=query_type,
                group_by=["resourceId"],
                compartment_depth=6,
                filter=oci.usage_api.models.Filter(
                    operator="AND",
                    dimensions=[
                        oci.usage_api.models.Dimension(
                            key="resourceId",
                            value=resource_ocid)])
            )
        )
    except Exception as e:
        logging.error(e)
        logging.error(f"OCI {query_type.capitalize()} metrics Validation is Failed!")
        raise e
    else:
        logging.info(f"Successfully retrieved Resource: {resource_ocid} {query_type} data.")
        return request_summarized_usages_response.data.items


def get_resource_ocid(subscription: str, resource_group_name: str, resource_name: str):
    headers: dict = {"Authorization": f"Bearer {os.environ.get('AZ_AUTH_TOKEN')}".replace("\"", "")}
    resource_url: str = f"https://management.azure.com/subscriptions/{subscription}/resourceGroups/{resource_group_name}/resources?$filter=name%20eq%20'{resource_name}'&api-version=2021-04-01"
    httprequest: urllib.request.Request = urllib.request.Request(
        resource_url, headers=headers, method="GET"
    )
    try:
        resource_id: str = json.loads(urllib.request.urlopen(httprequest).read()).get("value")[0].get("id")
        resource_json_url: str = f"https://management.azure.com{resource_id}?api-version=2023-09-01"

        httprequest: urllib.request.Request = urllib.request.Request(
            resource_json_url, headers=headers, method="GET"
        )
        resource_json: dict = json.loads(urllib.request.urlopen(httprequest).read())
        resource_ocid: str = resource_json.get("properties").get("ocid")
        return resource_ocid
    except urllib.error.HTTPError as e:
        logging.error(f"Failed to Get resource OCID. {e.status} {e.reason} {headers}.")
        raise e
    except (AttributeError, TypeError, json.JSONDecodeError) as e:
        logging.error(f"Failed to Get resource OCID. {e}.")
        raise e


def verify_azure_billing_usage_metrics(subscriptionId):
    url = f"https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.CostManagement/query?api-version=2023-11-01"
    headers: dict = {"Authorization": f"Bearer {os.environ.get('AZ_AUTH_TOKEN')}".replace("\"", ""),
                     "Content-Type": "application/json; charset=UTF-8"}
    request_body = {"type": "ActualCost",
                    "timeframe": "WeekToDate",
                    "dataset": {
                        "granularity": "Daily",
                        "aggregation": {
                        },
                        "grouping": [
                        ]
                    }}
    httprequest: urllib.request.Request = urllib.request.Request(
        url, headers=headers, method="POST", data=json.dumps(request_body).encode()
    )
    try:
        costs: str = json.loads(urllib.request.urlopen(httprequest).read()).get("properties").get("rows")
        if len(costs) > 0:
            logging.info(f"Azure Billing metrics Validation is Passed!")
        else:
            logging.error(f"Azure Billing metrics is empty and Validation is Failed!")
    except urllib.error.HTTPError as e:
        logging.error(f"{e.status} {e.reason}.")
        logging.error(f"Azure Billing metrics Validation is Failed!")
        raise e
    except (AttributeError, TypeError, json.JSONDecodeError) as e:
        logging.error(f"{e}.")
        logging.error(f"Azure Billing metrics Validation is Failed!")
        raise e


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('-p', '--config_file_profile', default='DEFAULT',
                        help='OCI auth profile name.',
                        required=False)
    parser.add_argument('-s', '--azure_subscription',
                        help='Azure subscription.',
                        required=True)
    parser.add_argument('-g', '--resource_group_name',
                        help='The resource group name.',
                        required=True)
    parser.add_argument('-n', '--resource_name',
                        help='The resource name.',
                        required=True)
    parser.add_argument('-t', '--oci_tenant_id',
                        help='The Id of the OCI tenancy.',
                        required=True)
    args = parser.parse_args()
    ocid = get_resource_ocid(subscription=args.azure_subscription,
                             resource_group_name=args.resource_group_name,
                             resource_name=args.resource_name)
    verify_oci_billing_usage_metrics(resource_ocid=ocid,
                                     config_file_profile=args.config_file_profile,
                                     tenant_id=args.oci_tenant_id)
    verify_azure_billing_usage_metrics(subscriptionId=args.azure_subscription)
