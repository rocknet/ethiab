const ethers = require('ethers');
const fs = require('fs');
const YAML = require('yaml');

function init() {
    const mnemonicFile = fs.readFileSync('/root/data/mnemonic.yaml', 'utf8');
    const mnemonicYaml = YAML.parse(mnemonicFile);

    // Get the first EOA address from the mnemonic
    const wallet = ethers.Wallet.fromPhrase(mnemonicYaml.mnemonic);

    // Write the node EOA address, to be used for fee recipient and for reference
    const info = {
      mnemonic: mnemonicYaml.mnemonic,
      eoa_address: wallet.address,
      eoa_private_key: wallet.privateKey
    }

    fs.writeFileSync('/root/ethiab_info.json', JSON.stringify(info, null, 2));
}

init();
