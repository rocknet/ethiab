#!/usr/bin/env sh

if [ "$ENABLE_EXTERNAL_DISCOVERY" != "true" ]; then
  echo "** ethiab ** External discovery is disabled, skipping p2p info collection"
  exit 0
else
  echo "** ethiab ** Installing curl, jq"
  apk update
  apk add curl jq

  echo "** ethiab ** Getting enode from ec2"
  enode=$(curl --data '{"method":"admin_nodeInfo","id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST 172.16.8.3:8545 -s | jq -r '.result.enode')
  echo "** ethiab ** enode: $enode"

  echo "** ethiab ** Getting enr from bc2"
  enr=$(curl http://172.16.8.6:9596/eth/v1/node/identity -s | jq -r '.data.enr')
  echo "** ethiab ** enr: $enr"

  echo "** ethiab ** Writing enode and enr to json file"
  jq -n --arg enode "$enode" --arg enr "$enr" '{ enode: $enode, enr: $enr }' > /usr/share/nginx/html/ethiab-bootnodes.json

  cp execution/genesis.json /usr/share/nginx/html
  cp consensus/config.yaml /usr/share/nginx/html
  cp consensus/genesis.ssz /usr/share/nginx/html

  mkdir -p /usr/share/nginx/html/mnemonics
  cp consensus/mnemonics/*.yaml /usr/share/nginx/html/mnemonics

  exec nginx -g "daemon off;"
fi

