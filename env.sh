# for Azure Terraform & CLI
# https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure-with-service-principle
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID
az account show -o table

# for OCI Terraform
# https://docs.oracle.com/en-us/iaas/Content/terraform/configuring.htm#api-key-auth
export TF_VAR_oci_tenancy_ocid="OCID of the OCI tenancy"
export TF_VAR_oci_user_ocid="<OCID of the OCI user>"
export TF_VAR_oci_private_key_path="<path (including filename) of the private key>"
export TF_VAR_oci_fingerprint="<Key's fingerprint>"

# for OCI CLI
# https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clienvironmentvariables.htm
export OCI_CLI_TENANCY=$TF_VAR_oci_tenancy_ocid
export OCI_CLI_USER=$TF_VAR_oci_user_ocid
export OCI_CLI_FINGERPRINT=$TF_VAR_oci_fingerprint
export OCI_CLI_KEY_FILE=$TF_VAR_oci_private_key_path
oci iam tenancy get --tenancy-id $TF_VAR_oci_tenancy_ocid --output table --query "data.{Name:name, OCID:id}" --auth api_key

