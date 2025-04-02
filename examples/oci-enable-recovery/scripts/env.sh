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

