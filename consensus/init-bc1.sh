#!/usr/bin/env sh

echo "** ethiab ** Installing curl for health check"
apk update
apk add curl

echo "** ethiab ** Initializing Lodestar Beacon"

exec node --max-old-space-size=4096 ./packages/cli/bin/lodestar beacon \
  --execution.urls "http://172.16.8.2:8551" \
  --jwt-secret "/root/data/execution/1/geth/jwtsecret" \
  --dataDir "/root/data/consensus/1" \
  --paramsFile "/root/consensus/config.yaml" \
  --genesisStateFile "/root/consensus/genesis.ssz" \
  --enr.ip 172.16.8.5 \
  --rest.address 0.0.0.0 \
  --subscribeAllSubnets true "$@"
