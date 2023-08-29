#!/usr/bin/env sh

genesis_timestamp=$(curl http://172.16.8.5:9596/eth/v1/beacon/genesis -s | jq -r '.data.genesis_time')

echo "Updating GENESIS_TIMESTAMP in settings.py to $genesis_timestamp"
sed -i '/GENESIS_TIMESTAMP/s/1.*/'"$genesis_timestamp"'/' /opt/ethstakersclub/settings.py

python manage.py makemigrations
python manage.py migrate
python manage.py migrate --database=userdata

python manage.py createsuperuser --database=userdata --noinput

exec python manage.py runserver 0.0.0.0:8000
