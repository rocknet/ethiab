#!/usr/bin/env sh

echo "** ethiab ** Installing curl, jq"
apk update
apk add curl jq

echo "** ethiab ** Getting enr from bc1"
enr=$(curl http://172.16.8.5:9596/eth/v1/node/identity -s | jq -r '.data.enr')
echo "** ethiab ** enr: $enr"

if [ "$ENABLE_EXTERNAL_DISCOVERY" == "true" ]; then
  echo "** ethiab ** Getting external IP, to set on enr"
  external_ip=$(curl https://ipinfo.io/ip -s)

  echo "** ethiab ** Initializing Lodestar Beacon"

  exec node --max-old-space-size=4096 ./packages/cli/bin/lodestar beacon \
    --execution.urls "http://172.16.8.3:8551" \
    --jwt-secret "/root/data/execution/2/geth/jwtsecret" \
    --dataDir "/root/data/consensus/2" \
    --paramsFile "/root/consensus/config.yaml" \
    --genesisStateFile "/root/consensus/genesis.ssz" \
    --port "$BN_P2P_HOST_PORT" \
    --enr.ip "$external_ip" \
    --nat \
    --rest.address 0.0.0.0 \
    --network.connectToDiscv5Bootnodes true \
    --bootnodes "$enr" \
    --subscribeAllSubnets true "$@"
else
  echo "** ethiab ** Initializing Lodestar Beacon"

  exec node --max-old-space-size=4096 ./packages/cli/bin/lodestar beacon \
    --execution.urls "http://172.16.8.3:8551" \
    --jwt-secret "/root/data/execution/2/geth/jwtsecret" \
    --dataDir "/root/data/consensus/2" \
    --paramsFile "/root/consensus/config.yaml" \
    --genesisStateFile "/root/consensus/genesis.ssz" \
    --rest.address 0.0.0.0 \
    --network.connectToDiscv5Bootnodes true \
    --bootnodes "$enr" \
    --subscribeAllSubnets true "$@"
fi
