#!/usr/bin/env bash
# docs/superpowers/verify-smoke-test.sh
# Smoke tests this config in isolation, without touching the real
# ~/.config/nvim or ~/.local/share/nvim.
set -euo pipefail

TMP_CONFIG="$(mktemp -d)"
TMP_DATA="$(mktemp -d)"
TMP_STATE="$(mktemp -d)"
TMP_CACHE="$(mktemp -d)"

cleanup() { rm -rf "$TMP_CONFIG" "$TMP_DATA" "$TMP_STATE" "$TMP_CACHE"; }
trap cleanup EXIT

echo "==> Copying config to temp dir..."
cp -r ~/.config/nvim/. "$TMP_CONFIG/"

echo "==> Launching nvim with isolated XDG dirs..."
XDG_CONFIG_HOME="$(dirname "$TMP_CONFIG")" \
XDG_DATA_HOME="$TMP_DATA" \
XDG_STATE_HOME="$TMP_STATE" \
XDG_CACHE_HOME="$TMP_CACHE" \
nvim --headless \
  -c "autocmd User LazyDone ++once lua vim.schedule(vim.cmd.qa)" \
  -c "lua vim.defer_fn(vim.cmd.qa, 60000)" \
  2>&1 | tee "$TMP_CACHE/nvim.log"

if grep -i -E "error|E[0-9]+:" "$TMP_CACHE/nvim.log" | grep -v "no errors"; then
  echo "❌ Smoke test FAILED — see errors above"
  exit 1
fi

echo "✅ Smoke test passed"
