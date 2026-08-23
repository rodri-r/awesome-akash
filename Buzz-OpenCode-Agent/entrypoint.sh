#!/bin/sh
set -e

CONFIG_DIR="/root/.config/opencode"
AUTH_DIR="/root/.local/share/opencode"
mkdir -p "$CONFIG_DIR" "$AUTH_DIR"

# Write provider config to the correct location
cat > "$CONFIG_DIR/opencode.json" << JSONEOF
{
  "permission": {
    "edit": "allow",
    "bash": "allow",
    "webfetch": "allow"
  },
  "provider": {
    "akashml": {
      "name": "AkashML",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "${OPENCODE_BASE_URL}"
      },
      "models": {
        "${OPENCODE_MODEL}": {
          "name": "${OPENCODE_MODEL}"
        }
      }
    }
  },
  "model": "akashml/${OPENCODE_MODEL}"
}
JSONEOF

# Write auth credentials
cat > "$AUTH_DIR/auth.json" << JSONEOF
{
  "akashml": {
    "type": "api",
    "key": "${OPENCODE_API_KEY}"
  }
}
JSONEOF

echo "OpenCode config written to $CONFIG_DIR/opencode.json"
echo "Provider: ${OPENCODE_BASE_URL}"
echo "Model: ${OPENCODE_MODEL}"

exec buzz-acp \
    --relay-url "${BUZZ_RELAY_URL}" \
    --private-key "${BUZZ_PRIVATE_KEY}" \
    --agent-owner "${BUZZ_ACP_AGENT_OWNER}" \
    --agent-command opencode \
    --agent-args acp \
    --respond-to owner-only \
    --subscribe all \
    --mcp-command "" \
    --max-turn-duration 7200 \
    --idle-timeout 120
