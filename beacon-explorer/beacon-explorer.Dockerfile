FROM python:3.10-bullseye

RUN apt-get update && apt install jq -y

WORKDIR /opt

ENV VIRTUAL_ENV=/opt/.venv/ethstakersclub
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN git clone https://github.com/ethstakersclub/ethstakersclub.git

WORKDIR /opt/ethstakersclub
RUN git checkout custom-testnet

RUN pip install -r requirements.txt

COPY settings.py .
