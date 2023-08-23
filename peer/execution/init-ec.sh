#!/usr/bin/env sh

echo "** ethiab ** Initializing geth"

geth init \
  --datadir "/root/data/execution" \
  /root/data/genesis.json

echo "** ethiab ** Installing curl, jq, and GNU sed"
apk update
apk add curl jq sed

echo "** ethiab ** Getting enode from bootnodes file"
enode=$(cat /root/data/ethiab-bootnodes.json | jq '.enode')
echo "** ethiab ** enode: $enode"

echo "** ethiab ** Setting enode in ec.toml"
# We use pipe delimeter due to the forward slashes in enode
sed -i '/BootstrapNodes/,/BootstrapNodesV5/s|\[.*\]|['"${enode}"']|' /root/execution/ec.toml

echo "** ethiab ** Getting external IP, to set on enode"
external_ip=$(curl https://ipinfo.io/ip -s)

echo "** ethiab ** starting geth"
exec geth \
  --config /root/execution/ec.toml \
  --port "$EC_P2P_HOST_PORT" \
  --discovery.port "$EC_P2P_HOST_PORT" \
  --nat extip:"$external_ip" \
  --http="$ENABLE_EC_RPC" \
  --http.addr "0.0.0.0" "$@"
