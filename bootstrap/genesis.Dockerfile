FROM golang

WORKDIR /opt

RUN git clone https://github.com/protolambda/eth2-testnet-genesis.git

WORKDIR /opt/eth2-testnet-genesis

RUN go build

ENTRYPOINT /root/consensus/init-genesis.sh
