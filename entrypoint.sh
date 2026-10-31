#!/bin/sh
set -eu

: "${COBALT_API_KEY:?COBALT_API_KEY must be configured in Render}"

umask 077
KEYS_FILE="/tmp/cobalt-api-keys.json"
printf '{"%s":{"name":"undersand-backend","limit":20,"allowedServices":["tiktok","instagram","facebook","youtube"]}}\n' "$COBALT_API_KEY" > "$KEYS_FILE"
chmod 600 "$KEYS_FILE"

# This instance is a private provider for Undersand, not a public Cobalt frontend.
export API_KEY_URL="file://${KEYS_FILE}"
export API_AUTH_REQUIRED="1"
export CORS_WILDCARD="0"
export CORS_URL="${COBALT_CORS_ORIGIN:-https://undersand.pages.dev}"
export TURNSTILE_SITEKEY=""
export TURNSTILE_SECRET=""
export JWT_SECRET=""

exec node src/cobalt
