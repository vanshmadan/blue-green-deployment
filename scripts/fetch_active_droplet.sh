#!/bin/bash
set -e

FLOATING_IP="$1"
FALLBACK_ID="$2"
DO_API_TOKEN="${DO_API_TOKEN:-}"

if [ -z "$DO_API_TOKEN" ]; then
  echo "Missing DO_API_TOKEN" >&2
  exit 1
fi

response=$(curl -s -H "Authorization: Bearer $DO_API_TOKEN" \
  "https://api.digitalocean.com/v2/floating_ips/${FLOATING_IP}")

droplet_id=$(echo "$response" | jq -r '.floating_ip.droplet.id')

if [ "$droplet_id" == "null" ] || [ -z "$droplet_id" ]; then
  droplet_id="$FALLBACK_ID"
fi

echo "{\"active_droplet_id\": \"$droplet_id\"}"
