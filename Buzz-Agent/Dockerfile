# ── Stage 1: Builder ─────────────────────────────────────────────────────────
FROM rust:1.88-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN git clone --depth=1 https://github.com/block/buzz.git .

RUN cargo build --release \
    -p buzz-acp \
    -p buzz-agent \
    -p buzz-dev-mcp \
    -p buzz-cli \
    && strip target/release/buzz-acp \
    && strip target/release/buzz-agent \
    && strip target/release/buzz-dev-mcp \
    && strip target/release/buzz


# ── Stage 2: Runtime ─────────────────────────────────────────────────────────
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/buzz-acp     /usr/local/bin/buzz-acp
COPY --from=builder /build/target/release/buzz-agent   /usr/local/bin/buzz-agent
COPY --from=builder /build/target/release/buzz-dev-mcp /usr/local/bin/buzz-dev-mcp
COPY --from=builder /build/target/release/buzz         /usr/local/bin/buzz

ENV BUZZ_ACP_AGENT_COMMAND=buzz-agent

ENTRYPOINT ["/usr/local/bin/buzz-acp"]
