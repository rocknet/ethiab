#!/usr/bin/env sh

echo "** ethiab ** Installing yq"
pip install yq

echo "** ethiab ** Getting mnemonic from yaml file"
mnemonic=$(cat /root/consensus/mnemonics.yaml | yq -r .[0].mnemonic)
count=$(cat /root/consensus/mnemonics.yaml | yq -r .[0].count)

echo "** ethiab ** Running deposit-staking-cli to generator validator keys"
./deposit.sh \
  --language English \
  --non_interactive \
  existing-mnemonic \
  --mnemonic "$mnemonic" \
  --validator_start_index 0 \
  --num_validators $count \
  --folder /root/consensus \
  --chain mainnet \
  --keystore_password password

echo "**ethiab ** writing validator key password to password file"
echo password > /root/consensus/validator_keys/password.txt

