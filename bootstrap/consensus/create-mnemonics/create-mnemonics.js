const ethers = require('ethers');
const fs = require('fs');
const YAML = require('yaml');

function init() {
    const participantsFile = fs.readFileSync('/root/consensus/participants.yaml', 'utf8');
    const participants = YAML.parse(participantsFile);

    var mnemonics = [];
    fs.mkdirSync('/root/consensus/mnemonics');

    const validatorCount = parseInt(process.env.VALIDATOR_COUNT_PER_PARTICIPANT);

    // for each item in participants.yaml, create a mnemonic, add to array, write to file
    participants.forEach(item => {
        let mnemonic = ethers.Mnemonic.fromEntropy(ethers.randomBytes(16));
        let peerMnemonicData = {"mnemonic": mnemonic.phrase, "count": validatorCount};
        mnemonics.push(peerMnemonicData);

        if (item !== 'bootnode') {
            // Write file with the mnemonic to serve to participants, so they can generate keys
            fs.writeFileSync('/root/consensus/mnemonics/' + item + '.yaml', YAML.stringify(peerMnemonicData));
        }
    });

    // write the full list of mnemonics for the genesis state creation process
    fs.writeFileSync('/root/consensus/mnemonics.yaml', YAML.stringify(mnemonics));
}

init();
