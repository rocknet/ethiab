FROM python:3.10-bullseye

WORKDIR /opt

RUN git clone https://github.com/ethereum/staking-deposit-cli.git

WORKDIR /opt/staking-deposit-cli

RUN ./deposit.sh install; exit 0

ENTRYPOINT /root/consensus/init-staking-deposit.sh 
