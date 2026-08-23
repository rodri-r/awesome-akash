# Buzz Agent on Akash

Run a headless AI agent connected to a [Buzz](https://github.com/block/buzz) relay on Akash Network. The agent listens for mentions in Buzz channels and responds using your chosen LLM provider.

## What is Buzz?

Buzz is an open-source, AI-native communication platform by Block. It runs on the Nostr protocol and is designed for human-agent collaboration. Teams can communicate alongside AI agents in shared channels.

## What does this deploy?

This SDL deploys a containerized Buzz agent that:

- Connects to any Buzz relay using a Nostr keypair
- Listens for @mentions in channels it belongs to
- Responds using your LLM provider (AkashML, Anthropic, OpenRouter, or Groq)
- Runs fully headless with no desktop app required on the host

## Prerequisites

You need a running Buzz relay before deploying an agent. You can run your own using the [official Buzz deploy/compose stack](https://github.com/block/buzz/tree/main/deploy/compose), or deploy one directly on Akash using the [Buzz Relayer SDL](https://github.com/akash-network/awesome-akash/tree/master/Buzz-Relayer) available in the Akash Console and Console Air templates.

You also need the [Buzz Desktop app](https://github.com/block/buzz/releases) to manage your relay and add the agent to channels.

## Setup

**1. Generate an agent keypair**

Each agent needs its own unique Nostr identity. You can generate a keypair using the official Buzz image:

```bash
docker run --rm --entrypoint /usr/local/bin/buzz-admin ghcr.io/block/buzz:main generate-key
```

Or if you have the `buzz-admin` binary installed locally:

```bash
buzz-admin generate-key
```

Both commands output a hex secret key and hex public key. The secret key goes in the SDL as `BUZZ_PRIVATE_KEY`.

To convert your hex keys to npub/nsec format for use with other Nostr tools, install the `nostr-tool` CLI:

```bash
cargo install nostr-tool
nostr-tool key convert --secret-key YOUR_HEX_SECRET_KEY
```

This outputs the matching `nsec1...` and `npub1...` Bech32 encoded keys. The Buzz relay and agent accept both hex and nsec1 format for `BUZZ_PRIVATE_KEY`.

**2. Add the agent as a relay member**

In the Buzz Desktop app, go to Settings, then Invites, and invite the agent's public key as a member of your community.

**3. Fill in the SDL**

Update all `REPLACE_WITH_*` values in the SDL before deploying.

**4. Deploy on Akash**

Deploy using [console.akash.network](https://console.akash.network) or [air.akash.network](https://air.akash.network).

**5. Publish the agent profile**

After deployment, shell into the running container and publish a profile so the agent appears by name in the Desktop app:

```bash
BUZZ_RELAY_URL=ws://your-relay-url:port \
BUZZ_PRIVATE_KEY=your-agent-secret-key \
buzz users set-profile --name "YourAgentName"
```

**6. Add the agent to a channel**

In the Buzz Desktop app, open a channel, go to Members, search for the agent by name and add it. The agent will start responding to @mentions immediately.

## LLM Providers

The SDL includes four provider options. Uncomment the one you want to use and comment out the others.

AkashML is recommended when running on Akash as it keeps everything within the Akash ecosystem. Available models include `deepseek-ai/DeepSeek-V4-Flash-0731`, `meta-llama/Llama-3.3-70B-Instruct`, and `Qwen/Qwen3.8-27B`.

## Environment Variables

| Variable | Description |
|---|---|
| `BUZZ_PRIVATE_KEY` | Agent Nostr secret key (hex or nsec1 format) |
| `BUZZ_RELAY_URL` | WebSocket URL of your Buzz relay |
| `BUZZ_ACP_AGENT_OWNER` | Your hex pubkey, only you can interact with the agent |
| `BUZZ_ACP_RESPOND_TO` | Set to `owner-only` to restrict access |
| `BUZZ_ACP_MCP_COMMAND` | MCP server for tools, set to `buzz-dev-mcp` |
| `BUZZ_ACP_MAX_TURNS_PER_SESSION` | Max LLM turns per session (recommended: 20) |
| `BUZZ_ACP_IDLE_TIMEOUT` | Seconds before idle turn is cancelled (recommended: 120) |
| `BUZZ_AGENT_PROVIDER` | LLM provider: `openai`, `anthropic`, `openrouter`, or `groq` |

## Building the image yourself

The Dockerfile is included if you want to build your own image. It compiles `buzz-acp`, `buzz-agent`, `buzz-dev-mcp` and `buzz-cli` from the official Buzz source.

```bash
docker buildx build --platform linux/amd64 -t your-username/buzz-agent:1.0 . --push
```

## Resources

- [Buzz GitHub](https://github.com/block/buzz)
- [Block Engineering Blog: Run Your Own Buzz Relay](https://engineering.block.xyz/blog/run-your-own-buzz-relay)
- [Akash Network](https://akash.network)
