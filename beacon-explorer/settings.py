from datetime import datetime
from django.utils import timezone
from web3 import Web3
import os
from pathlib import Path

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure--SmwPstcJFmjGzqJeUOXjpfVGNM2HFZfZWSIZlquxx4AUbbJEY4EFHNmkWj3pT4NG'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/4.2/howto/static-files/

STATIC_URL = 'static/'

STATICFILES_DIRS = [
    BASE_DIR / "static",
]

STATIC_ROOT = "/var/www/static/"
BLOCKPRINT_API_URL = "https://api.blockprint.sigp.io"
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR,'templates')],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                'frontend.context_processors.general_context_processor',
            ],
        },
    },
]

# Database
# https://docs.djangoproject.com/en/4.2/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'ethstakersclub',
        'USER': 'ethstakersclub',
        'PASSWORD': 'password',  # Or leave blank for no password
        'HOST': '172.16.8.10',
        'PORT': '5432',
    },
    'userdata': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'userdata.db'),
    }
}

CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://172.16.8.11:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

DATABASE_ROUTERS = ['ethstakersclub.routers.UserdataRouter']

ALLOWED_HOSTS = os.environ.get('SERVERNAMES').split(' ')


CELERY_BROKER_URL = 'redis://172.16.8.11:6379/0'
CELERY_RESULT_BACKEND = 'redis://172.16.8.11:6379/0'

# Celery configuration
CELERY_BEAT_SCHEDULER = 'django_celery_beat.schedulers:DatabaseScheduler'
CELERY_BROKER_TRANSPORT_OPTIONS = {'visibility_timeout': 360}
CELERYD_MAX_TASKS_PER_CHILD = 1
CELERYD_PREFETCH_MULTIPLIER = 1
CELERY_ACKS_LATE = 1
CELERY_IGNORE_RESULT = True
CELERY_STORE_ERRORS_EVEN_IF_IGNORED = True
BROKER_POOL_LIMIT = 30

# api endpoints
BEACON_API_ENDPOINT = "http://172.16.8.5:9596"
BEACON_API_ENDPOINT_OPTIONAL_GZIP = BEACON_API_ENDPOINT
EXECUTION_HTTP_API_ENDPOINT = "http://172.16.8.2:8545"

# chain settings
SLOTS_PER_EPOCH = 32
SECONDS_PER_SLOT = 12
BALANCE_PER_VALIDATOR = 32
GENESIS_TIMESTAMP = 1693068276
MERGE_SLOT = 0
CHURN_LIMIT_QUOTIENT = 65536
MIN_PER_EPOCH_CHURN_LIMIT = 4
EPOCH_REWARDS_HISTORY_DISTANCE = 0
DEPOSIT_CONTRACT_ADDRESS = '0x000000006465706F73697420636f6E7472616374'
DEPOSIT_CONTRACT_DEPLOYMENT_BLOCK = 0
ALTAIR_EPOCH = 0

#calculated
GENESIS_TIME = timezone.make_aware(datetime.fromtimestamp(GENESIS_TIMESTAMP), timezone=timezone.utc)
w3 = Web3(Web3.HTTPProvider(EXECUTION_HTTP_API_ENDPOINT))
MAX_SLOTS_PER_DAY = 60*60*24/SECONDS_PER_SLOT

# frontend/api
VALIDATOR_MONITORING_LIMIT=200
CURRENCY_NAME = "ETH"
ATTESTATION_EFFICIENCY_EPOCHS = 100

# Sync
SNAPSHOT_CREATION_EPOCH_DELAY_SYNC = 120
EPOCH_REWARDS_HISTORY_DISTANCE_SYNC = 10
MAX_TASK_QUEUE = 100


MEV_BOOST_RELAYS = {
    "Flashbots": "https://boost-relay.flashbots.net",
    "BloXroute Max Profit": "https://bloxroute.max-profit.blxrbdn.com",
#    "BloXroute Ethical": "https://bloxroute.ethical.blxrbdn.com",
    "BloXroute Regulated": "https://bloxroute.regulated.blxrbdn.com",
    "Blocknative": "https://builder-relay-mainnet.blocknative.com",
    "Manifold": "https://mainnet-relay.securerpc.com",
    "Eden": "https://relay.edennetwork.io",
#    "Relayooor": "https://relayooor.wtf",
    "Agnostic Relay": "https://agnostic-relay.net",
    "ultra sound relay": "https://relay.ultrasound.money"
}
