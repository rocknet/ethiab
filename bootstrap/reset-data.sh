#!/usr/bin/env sh

docker compose down
sudo rm -rf data
sudo rm -rf consensus/validator_keys
sudo rm -rf consensus/tranches
sudo rm -rf consensus/mnemonics
rm -f consensus/genesis.ssz
rm -f consensus/mnemonics.yaml
