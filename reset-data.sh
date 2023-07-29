#!/usr/bin/env sh

docker compose down
sudo rm -rf data
sudo rm -rf consensus/validator_keys
sudo rm -rf consensus/tranches
rm -f consensus/genesis.ssz
rm -f consensus/deposit_contract_block.txt
