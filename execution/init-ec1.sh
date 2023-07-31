#!/usr/bin/env sh

echo "** ethiab ** Initializing geth"

geth init \
  --datadir "/root/data/execution/1" \
  /root/execution/genesis.json

echo "** ethiab ** Starting geth"

exec geth \
  --config /root/execution/ec1.toml "$@"
