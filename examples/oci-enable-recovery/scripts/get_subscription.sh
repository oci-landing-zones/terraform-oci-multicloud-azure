#!/bin/bash
oci organizations assigned-subscription list -c $TF_VAR_oci_tenancy_ocid --all | jq -r '{ "id": .data.items[] | select (.["service-name"] == "ORACLEDBATAZURE") | .id }'
