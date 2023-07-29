#!/usr/bin/env sh

echo "** ethiab ** Installing pyyaml"
pip install pyyaml

echo "** ethiab ** Getting mnemonic from yaml file"
mnemonic=$(python /root/consensus/get-mnemonic.py)

echo "** ethiab ** Running deposit-staking-cli to generator validator keys"
./deposit.sh \
  --language English \
  --non_interactive \
  existing-mnemonic \
  --mnemonic "$mnemonic" \
  --validator_start_index 0 \
  --num_validators 8 \
  --folder /root/consensus \
  --chain mainnet \
  --keystore_password password

echo "**ethiab ** writing validator key password to password file"
echo password > /root/consensus/validator_keys/password.txt

