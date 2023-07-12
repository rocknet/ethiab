#!/usr/bin/env sh

echo "Initializing geth"

geth init \
  --datadir "/root/data/execution/1" \
  /root/execution/genesis.json

echo "Starting geth"

geth \
  --config /root/execution/ec1.toml
