import oci


def get_signer(config_file_profile) -> oci.auth.signers.SecurityTokenSigner:
    config = oci.config.from_file(profile_name=config_file_profile)
    if "security_token_file" in config:
        token_file = config['security_token_file']
        token = None
        with open(token_file, 'r') as f:
            token = f.read()
        private_key = oci.signer.load_private_key_from_file(config['key_file'])
    return oci.auth.signers.SecurityTokenSigner(token, private_key)
