const ethers = require('ethers');
const fs = require('fs');
const YAML = require('yaml');

function init() {
    const participantsFile = fs.readFileSync('/root/consensus/participants.yaml', 'utf8');
    const participants = YAML.parse(participantsFile);

    const genesisFile = fs.readFileSync('/root/execution/genesis.json', 'utf8');
    const genesis = JSON.parse(genesisFile);

    var mnemonics = [];
    fs.mkdirSync('/root/consensus/mnemonics');

    const validatorCount = parseInt(process.env.VALIDATOR_COUNT_PER_PARTICIPANT);

    // For each item in participants.yaml, create a mnemonic, add to array, write to file.
    for (const item of participants) {
        const mnemonic = ethers.Mnemonic.fromEntropy(ethers.randomBytes(16));
        const peerMnemonicData = {"mnemonic": mnemonic.phrase, "count": validatorCount};
        mnemonics.push(peerMnemonicData);

        // Get the first EOA address from the mnemonic, add allocation
        const wallet = ethers.Wallet.fromPhrase(mnemonic.phrase);
        genesis.alloc[wallet.address] = { "balance": process.env.ETH_ALLOCATION };

        if (item === 'bootnode') {
            // Write the boot node EOA info, to be used for fee recipient and for reference

            const info = {
               mnemonic: mnemonic.phrase,
               eoa_address: wallet.address,
               eoa_private_key: wallet.privateKey
            }

            fs.writeFileSync('/root/ethiab_info.json', JSON.stringify(info, null, 2));
        }

        // As a fail-safe, skip any remaining items in participants.yaml if we're not peering externally.
        // This ensures only the boot node's validators are in the genesis state.
        if (process.env.ENABLE_EXTERNAL_DISCOVERY !== true) {
            break;
        }

        if (item !== 'bootnode') {
            // Write file with the mnemonic to serve to participants, so they can generate keys
            fs.writeFileSync('/root/consensus/mnemonics/' + item + '.yaml', YAML.stringify(peerMnemonicData));
        }
    }

    // Write the full list of mnemonics for the genesis state creation process
    fs.writeFileSync('/root/consensus/mnemonics.yaml', YAML.stringify(mnemonics));

    // Save alloc changes to genesis.json
    fs.writeFileSync('/root/execution/genesis.json', JSON.stringify(genesis, null, 2));
}

init();
