#!/usr/bin/env sh

echo "** ethiab ** Installing curl, jq"
apk update
apk add curl jq

echo "** ethiab ** Getting enr from bootnodes file"
enr=$(cat /root/data/ethiab-bootnodes.json | jq -r '.enr')
echo "** ethiab ** enr: $enr"

echo "** ethiab ** Getting external IP, to set on enr"
external_ip=$(curl https://ipinfo.io/ip -s)

echo "** ethiab ** Initializing Lodestar Beacon"

exec node --max-old-space-size=4096 ./packages/cli/bin/lodestar beacon \
  --execution.urls "http://172.16.9.2:8551" \
  --jwt-secret "/root/data/execution/geth/jwtsecret" \
  --dataDir "/root/data/consensus" \
  --paramsFile "/root/data/config.yaml" \
  --genesisStateFile "/root/data/genesis.ssz" \
  --port "$BN_HOST_PORT" \
  --enr.ip "$external_ip" \
  --nat \
  --rest.address 0.0.0.0 \
  --network.connectToDiscv5Bootnodes true \
  --bootnodes "$enr" \
  --subscribeAllSubnets true "$@"
