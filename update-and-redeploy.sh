#!/usr/bin/env bash
set -euo pipefail

cd /root/openclaw

BRANCH="${1:-deploy/vps-baseline}"

# Sync remotes
git fetch origin --prune
git fetch upstream --prune

# Ensure branch exists locally
if ! git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  git checkout -b "$BRANCH" "origin/$BRANCH"
else
  git checkout "$BRANCH"
fi

# Rebase your deploy branch onto latest upstream main
# Keeps your local hardening commit(s) on top.
git rebase upstream/main

# Push updated branch to your fork
git push origin "$BRANCH"

# Rebuild and restart gateway
DOCKER_BUILDKIT=1 docker build -t openclaw:local -f Dockerfile .
docker compose up -d --force-recreate openclaw-gateway

echo "Done. Current status:"
docker compose ps
