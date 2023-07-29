import yaml

with open("/root/consensus/mnemonic.yaml") as f:
        s = yaml.safe_load(f)

print(s[0]['mnemonic'])
