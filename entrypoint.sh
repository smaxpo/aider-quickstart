#!/bin/bash
set -euo pipefail

AUTH_DIR="/home/devuser/.config/aider-copilot"
AUTH_FILE="$AUTH_DIR/auth.json"
CLIENT_ID="Iv1.b507a08c87ecfe98"
API_BASE="https://api.githubcopilot.com"

get_json_value() {
  python3 -c "import sys,json; print(json.loads(sys.stdin.read())['$1'])"
}

load_token() {
  if [ -f "$AUTH_FILE" ]; then
    python3 -c "import sys,json; print(json.loads(open('$AUTH_FILE').read())['oauth_token'])" 2>/dev/null
  fi
}

save_token() {
  mkdir -p "$AUTH_DIR"
  python3 -c "import json; json.dump({'oauth_token':'$1'},open('$AUTH_FILE','w'),indent=2)"
}

device_code_flow() {
  echo "No Copilot OAuth token found. Starting device code authentication..."
  echo ""

  local response
  response=$(curl -s -X POST "https://github.com/login/device/code" \
    -H "Accept: application/json" \
    -d "client_id=$CLIENT_ID&scope=copilot")

  local device_code user_code verification_uri interval expires_in
  device_code=$(echo "$response" | get_json_value device_code)
  user_code=$(echo "$response" | get_json_value user_code)
  verification_uri=$(echo "$response" | get_json_value verification_uri)
  interval=$(echo "$response" | get_json_value interval)
  expires_in=$(echo "$response" | get_json_value expires_in)

  echo "Please visit: $verification_uri"
  echo "Enter code:   $user_code"
  echo ""
  echo "Waiting for authorization (expires in $((expires_in / 60)) minutes)..."

  local elapsed=0
  while [ "$elapsed" -lt "$expires_in" ]; do
    sleep "$interval"
    elapsed=$((elapsed + interval))

    local token_response
    token_response=$(curl -s -X POST "https://github.com/login/oauth/access_token" \
      -H "Accept: application/json" \
      -d "client_id=$CLIENT_ID&device_code=$device_code&grant_type=urn:ietf:params:oauth:grant-type:device_code")

    local error
    error=$(echo "$token_response" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('error',''))" 2>/dev/null || echo "parse_error")

    case "$error" in
      authorization_pending)
        continue
        ;;
      slow_down)
        interval=$((interval + 5))
        continue
        ;;
      "")
        local token
        token=$(echo "$token_response" | get_json_value access_token)
        if [ -n "$token" ]; then
          save_token "$token"
          echo "Authentication successful! Token saved."
          echo ""
          return 0
        fi
        ;;
      *)
        echo "Authentication failed: $error" >&2
        echo "Response: $token_response" >&2
        return 1
        ;;
    esac
  done

  echo "Authentication timed out. Please try again." >&2
  return 1
}

token=$(load_token || true)

if [ -z "$token" ]; then
  device_code_flow
  token=$(load_token)
fi

if [ -z "$token" ]; then
  echo "Error: Failed to obtain OAuth token." >&2
  exit 1
fi

export OPENAI_API_BASE="$API_BASE"
export OPENAI_API_KEY="$token"

exec aider "$@"
