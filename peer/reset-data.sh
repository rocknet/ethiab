#!/usr/bin/env sh

docker compose down
sudo rm -rf data
sudo rm -rf consensus/validator_keys
rm -f consensus/mnemonic.yaml
