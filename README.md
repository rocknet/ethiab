# ethiab - Ethereum in a Box
Ethereum in a Box takes its inspiration from the [excellent article](https://dev.to/q9/how-to-merge-an-ethereum-network-right-from-the-genesis-block-3454) from Afri at ChainSafe, which details how to stand up a local testnet, merged since genesis.  This project takes that a bit further by implementing all of the steps in shell scripts, Docker and Docker Compose files.  Furthermore, we enable the Shapella hardforks from genesis.

## What can Ethereum in a Box be used for?
You can use `ethiab` to learn how a private Ethereum network is bootstrapped and see it go through genesis, this is the boostrap mode.  You can also coordinate genesis with others, where a coordinator creates mnemonics for all participants, and participants download the config they need to participate.  

The `genesis.json` file is not currently setup with any allocations, and the validators have BLS withdrawal credentials at genesis, so there's no ETH to use.  I haven't even tested creating a new account using [Clef](https://geth.ethereum.org/docs/fundamentals/account-management).

In bootstrap mode, the containers run inside a Docker bridge network (172.16.8.0/24).  The P2P ports of ec2 bc2 are exposed out of the container to the host.  If you set `ENABLE_EXTERNAL_DISCOVERY` in the `.env` (the default), the `enode` of ec2 and `enr` record of bc2 will be set using the externally accessible IP address.  You'd then need to allow the P2P ports through firewalls and routers.

In peer mode, the containers run inside a Docker bridge network (172.16.9.0/24), the P2P ports are always exposed from the container to the host, and the `enode` and `enr` records are updated with the externally accessible IP address.

There is a list things of I'm intending to do, curently in this README, soon to be in the Issues tracker.

### A Note About Security
---
**This project is about bootstrapping a private / semi-private Ethereum testnet / devnet. By definition, any Ether associated with these networks will have no value at all.  With that in mind, security best practices have not necessarily been observed and nothing in this project should be referred to for configuring clients for Ethereum mainnet.  We are very clearly putting mnemonics in files, transmitting them over HTTP, using the password "password" for validator keys, etc.  Never do this.  Let's be careful out there.**

---

### Prerequisites
- Modern Linux shell
  - Developed / tested on `Debian 11`
  - Should work on modern `Ubuntu`
- `Docker` and `Docker Compose`
  - Tested with docker version v24.0.2, docker compose v2.8.1

### Bootstrap Mode Quickstart
1. Clone this repo
2. If you'll be coordinating with others, add a unique string for each participant in the list contained in `consensus/participants.yaml`.  Each key would be shared with a particpant.  Keep the keys simple, as they'll be used as the basis for a file for each participant, e.g. `peer1` becomes `peer1.yaml`.
3. You may want to adjust certain parameters in the .env file, like the EC and BN host ports, in case the ones in the committed .env file are already in use.
4. From the `ethiab/bootstrap` repo folder, running `docker compose up` will start the clients and countdown about five minutes to genesis, showing you the union of all container logs in the terminal (attached mode).  Running `docker compose up -d` will run all containers detached.
5. If you run in detached mode, to see a particular container logs, run `docker logs -f <containername>`, e.g. `docker logs -f ethiab-vc`, to see the validator client logs
6. To pass additional parameters to the EC, BN, and VC client, edit the `.env` file values.  This can be useful to increase log levels, for example.

### Peer Mode Quickstart
1. Clone this repo
2. Edit the .env file in the `ethiab/peer` folder, be sure to set the `PEER_KEY` and `BOOTNODE_IP` to the values provided to you from the testnet coordinator.  You may want to set the host ports as well, depending on your configuration and other network services you're running.
3. From the `ethiab/peer` repo folder, running `docker compose up` will start the clients, showing you the union of all container logs in the terminal (attached mode).  Running `docker compose up -d` will run all containers detached.
4. If you run in detached mode, to see a particular container logs, run `docker logs -f <containername>`, e.g. `docker logs -f ethiab-vc`, to see the validator client logs
5. To pass additional parameters to the EC, BN, and VC client, edit the `.env` file values.  This can be useful to increase log levels, for example.

### What's Going On Here?

First, if you haven't read Afri's article linked above, you should.  It does a good job of explaining how to get all the necessary pieces going to start up your own Ethereum network on your local machine.  Reading through that article will make everything else make more sense.

The list of steps to get the network going is a great use case for Docker Compose, which is used to orchestrate multiple Docker containers as a group.  We're having to deal with some apps that are already in Docker images, but we also need to clone and build GitHub repos to make some tools work.  As detailed as the article is, there are a lot of steps, and using Compose can make it close to one-step.  Here's an overview of each service:

#### Bootstrap Mode Services

- **config:** Runs a quick shell script in a `busybox` instance simply to synchronize the genesis start time between the EC `genesis.json` file and BN `config.yaml`.  Set to "now".
- **ec1:** Initializes EC genesis and starts Geth, becomes bootnode for ec2.
- **ec2:** Queries `enode` record from ec1, updates the BoostrapNodes entries in toml file to use ec1 as bootnode, initializes EC genesis and starts Geth.
- **mnemonics:** Builds and runs a custom `create-mnemonics.Dockerfile` which uses NodeJS to run a `create-menomonics.js` script, which iterates through the `participants.yaml` file, and creates mnemonics for each one, to be used in genesis state and creating validator keys.
- **genesis:** Builds and runs a custom `genesis.Dockerfile` which uses `Go` to build `eth2-testnet-genesis`, then runs a shell script to use the tool to generate the `genesis.ssz` file for BN clients
- **staking-deposit:** Builds and runs a custom `staking-deposit.Dockerfile` which uses a `python` image, clones the Ethereum `staking-deposit-cli`, parses the mnemonic.yaml file, and calls the `staking-deposit-cli` with necessary parameters to create the validator keys.
- **bc1:** Starts `lodestar beacon`, using ec1 as its execution client peer.  This container uses a healthcheck, so bc2 waits to start until bc1 is fully up.
- **bc2:** Queries bc1 for its `enr` record, then starts `lodestar beacon`, using bc1 as its bootnode.
- **vc:** Starts `lodestar validator`, using bc1 as its BN client, loads the validator keys generated by the staking-deposit container.
- **p2p-info:** Runs `nginx` to serve necessary informtion to peers, to be able to easily start their clients.

#### Peer Mode Services
- **get-bootstrap:** Downloads the necessary configuration for the EL client, BN client, and the assigned mnemonic to create validator keys locally.
- **staking-deposit:** Builds and runs a custom `staking-deposit.Dockerfile` which uses a `python` image, clones the Ethereum `staking-deposit-cli`, parses the mnemonic.yaml file, and calls the `staking-deposit-cli` with necessary parameters to create the validator keys.
- **ec:** Initializes EC genesis and starts Geth.
- **bc:** Starts `lodestar beacon`, using ec as its execution client peer.
- **vc:** Starts `lodestar validator`, using bc as its BN client, loads the validator keys generated by the staking-deposit container.

## Contributing

If you see something in this project that can be better, I'm happy to take PRs.  If something doesn't work but you can't fix it, feel free to open an issue and I'll try to take a look.  This is a side project for me, but I'm happy to help as I can.

## Known Issue
- Though clients are synchronizing between the bootstrap node and the peer node, I haven't seen the finalized block hash advance.  I'm not sure why right now.

## TODO:
- Create issues out of the items below:
- Provide for custom parameters like genesis start, genesis delay, fee recipient, etc.  Workaround for genesis delay as of now is to edit the GENESIS_DELAY parameter in `consensus/config.yaml`.
- Use sensible default fee recipient, like the first address generated by the mnemonic.
- Enable creation of 0x01 validators, as of now they use BLS withdrawal credentials.
- Add other EC and BN clients beyond Geth and Lodestar.

### Stretch Goals:
- EL / BN explorer containers
