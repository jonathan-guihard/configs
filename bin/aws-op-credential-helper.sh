#!/usr/bin/env bash
# AWS credential_process helper that fetches IAM credentials from 1Password.
# Usage: aws-op-credential-helper.sh <1password-item-id>
#
# In ~/.aws/config:
#   credential_process = /path/to/aws-op-credential-helper.sh <item-id>

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <1password-item-id>" >&2
  exit 1
fi

ITEM_ID="$1"

# Fetch both fields in a single op call (single biometric prompt)
json=$(op item get "$ITEM_ID" --format json --fields "aws_access_key_id,aws_secret_access_key")

access_key_id=$(echo "$json" | jq -r '.[] | select(.label == "aws_access_key_id") | .value')
secret_access_key=$(echo "$json" | jq -r '.[] | select(.label == "aws_secret_access_key") | .value')

if [[ -z "$access_key_id" || -z "$secret_access_key" ]]; then
  echo "Error: failed to retrieve credentials from 1Password item $ITEM_ID" >&2
  exit 1
fi

# Output in AWS credential_process format
# aws-vault requires Expiration and SessionToken even for static IAM keys
expiration=$(date -u -v+4H +"%Y-%m-%dT%H:%M:%SZ")

jq -n \
  --arg aki "$access_key_id" \
  --arg sak "$secret_access_key" \
  --arg exp "$expiration" \
  '{Version: 1, AccessKeyId: $aki, SecretAccessKey: $sak, SessionToken: "", Expiration: $exp}'
