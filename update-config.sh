#!/usr/bin/env sh

now="$(date +%s)"
nowhex="$(printf '%x\n' $now)"

echo "** ethiab ** Setting genesis start time to current time: ($(date)) in genesis.json and config.yaml"
echo "** ethiab ** Decimal: $now Hex: $nowhex"
echo "** ethiab ** Start time does not include the GENESIS_DELAY parameter"

sed -i '/"timestamp":/s/0x.*/'0x"$nowhex"'",/' /root/execution/genesis.json

sed -i '/MIN_GENESIS_TIME/s/1.*/'"$now"'/' /root/consensus/config.yaml

