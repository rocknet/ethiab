#!/usr/bin/env sh

echo "** ethiab ** Installing jq"
apt-get update && apt-get install jq -y

echo "** ethiab ** Getting genesis hash for consensus/config.yaml and deposit_contract_block.txt"
genesisHash=$(curl --data '{"method":"eth_getBlockByNumber","params":["0x0",false],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" \
        -X POST 172.16.8.2:8545 -s | jq -r '.result.hash')
echo "** ethiab ** hash: $genesisHash"

echo "** ethiab ** Setting genesis hash in consensus/config.yaml"
sed -i '/TERMINAL_BLOCK_HASH/s/0x.*/'"${genesisHash}"'/' /root/consensus/config.yaml

echo "$genesisHash" > /root/consensus/deposit_contract_block.txt

echo "** ethiab ** Running eth2-testnet-genesis"
./eth2-testnet-genesis capella \
  --config /root/consensus/config.yaml \
  --eth1-config /root/execution/genesis.json \
  --mnemonics /root/consensus/mnemonic.yaml \
  --state-output /root/consensus/genesis.ssz \
  --tranches-dir /root/consensus/tranches
