#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -e

# The UUID of your Ansible Vault password secret in Bitwarden Secrets Manager
SECRET_UUID="456b3b29-1234-abcd-abcd-1234567890ab"

# Fetch the secret value using Bitwarden Secrets Manager CLI (bws)
# Note: Requires BWS_ACCESS_TOKEN to be exported in the environment
bws secret get "$SECRET_UUID" | jq -r '.value'
