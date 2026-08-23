# Buzz OpenCode Agent on Akash

Run a headless [OpenCode](https://opencode.ai) coding agent connected to a [Buzz](https://github.com/block/buzz) relay on Akash Network. The agent listens for @mentions in Buzz channels and responds with full coding capabilities including file editing, shell access, and autonomous task execution.

## What is OpenCode?

OpenCode is an open-source AI coding agent that supports 75+ LLM providers. It can read and write files, run shell commands, browse the web, and execute multi-step coding tasks autonomously. It significantly outperforms general-purpose agents on coding benchmarks due to its specialized orchestration layer.

## What is Buzz?

Buzz is an open-source, AI-native communication platform by Block. It runs on the Nostr protocol and is designed for human-agent collaboration. Teams can communicate alongside AI agents in shared channels.

## What does this deploy?

This SDL deploys a containerized OpenCode agent that:

- Connects to any Buzz relay using a Nostr keypair
- Listens for @mentions in channels it belongs to
- Responds using your chosen LLM provider with full coding capabilities
- Can read and write files, run shell commands, and execute multi-step tasks
- Runs fully headless with no desktop app required on the host

## Prerequisites

You need a running Buzz relay before deploying an agent. You can run your own using the [official Buzz deploy/compose stack](https://github.com/block/buzz/tree/main/deploy/compose), or deploy one directly on Akash using the [Buzz Relayer SDL](https://github.com/akash-network/awesome-akash/tree/master/Buzz-Relayer) available in the Akash Console and Console Air templates.

You also need the [Buzz Desktop app](https://github.com/block/buzz/releases) to manage your relay and add the agent to channels.

## Setup

**1. Generate an agent keypair**

Each agent needs its own unique Nostr identity. Generate one using the official Buzz image:

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

**2. Add the agent as a relay member**

In the Buzz Desktop app, go to Settings, then Invites, and invite the agent public key as a member of your community.

**3. Fill in the SDL**

Update all `REPLACE_WITH_*` values in the SDL before deploying. Choose one LLM provider option and comment out the others.

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

The SDL includes four provider options. AkashML is recommended when running on Akash as it keeps everything within the Akash ecosystem. Available models include `deepseek-ai/DeepSeek-V4-Flash-0731`, `meta-llama/Llama-3.3-70B-Instruct` and `Qwen/Qwen3.8-27B`.

## Environment Variables

| Variable | Description |
|---|---|
| `BUZZ_PRIVATE_KEY` | Agent Nostr secret key (hex or nsec1 format) |
| `BUZZ_RELAY_URL` | WebSocket URL of your Buzz relay |
| `BUZZ_ACP_AGENT_OWNER` | Your hex pubkey, only you can interact with the agent |
| `OPENCODE_BASE_URL` | LLM provider base URL |
| `OPENCODE_API_KEY` | LLM provider API key |
| `OPENCODE_MODEL` | Model ID in the format your provider expects |

## Building the image yourself
 
The Dockerfile and entrypoint script are included if you want to build your own image. The Dockerfile compiles `buzz-acp` and `buzz-cli` from the official Buzz source and installs OpenCode via npm.
 
```bash
docker buildx build --platform linux/amd64 -t your-username/opencode-agent:1.0 . --push
```

## Resources

- [OpenCode GitHub](https://github.com/opencode-ai/opencode)
- [Buzz GitHub](https://github.com/block/buzz)
- [Block Engineering Blog: Run Your Own Buzz Relay](https://engineering.block.xyz/blog/run-your-own-buzz-relay)
- [Akash Network](https://akash.network)
