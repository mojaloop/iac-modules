# Environment Variable Management

This directory uses an `.envrc` file to manage sensitive environment variables for local development.

Variables must be prefixed with `CC_VAR_`. For example: `export CC_VAR_ssh_private_key="..."`.

These variables are consumed by the `scripts/dictmerge.py` script, which injects them into the configuration used by Terraform.

## Local Setup

1.  Copy the template: `cp .envrc.template .envrc`
2.  Fill in the values in the `.envrc` file.

The `.envrc` file is git-ignored and should not be committed.
