#!/bin/bash
set -e

FLOATING_IP="$1"
BLUE_ID="$2"
GREEN_ID="$3"
DO_API_TOKEN="${DO_API_TOKEN:-}"

if [ -z "$DO_API_TOKEN" ]; then
  echo "Missing DO_API_TOKEN" >&2
  exit 1
fi

# Step 1: Query the floating IP to get the currently assigned droplet
response=$(curl -s -H "Authorization: Bearer $DO_API_TOKEN" \
  "https://api.digitalocean.com/v2/floating_ips/${FLOATING_IP}")

assigned_id=$(echo "$response" | jq -r '.floating_ip.droplet.id')

# Step 2: If assigned_id is valid, return it
if [ "$assigned_id" != "null" ] && [ -n "$assigned_id" ]; then
  echo "{\"active_droplet_id\": \"$assigned_id\"}"
  exit 0
fi

# Step 3: Fallback — check if blue droplet still exists
blue_exists=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $DO_API_TOKEN" \
  "https://api.digitalocean.com/v2/droplets/${BLUE_ID}")

if [ "$blue_exists" = "200" ]; then
  echo "{\"active_droplet_id\": \"$BLUE_ID\"}"
  exit 0
fi

# Step 4: Else fallback to green (if it exists)
green_exists=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $DO_API_TOKEN" \
  "https://api.digitalocean.com/v2/droplets/${GREEN_ID}")

if [ "$green_exists" = "200" ]; then
  echo "{\"active_droplet_id\": \"$GREEN_ID\"}"
  exit 0
fi

# Step 5: Nothing exists — fail gracefully
echo "No valid droplet found for fallback" >&2
exit 1
