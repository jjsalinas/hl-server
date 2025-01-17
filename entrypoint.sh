#!/bin/bash

# Load environment variables from hlds.env
if [ -f /srv/hlds/hlds.env ]; then
  export $(cat /srv/hlds/hlds.env | grep -v '#' | awk '/=/ {print $1}')
fi

# Replace placeholders in default.cfg.template and save as default.cfg
envsubst < /srv/hlds/default.cfg.template > /srv/hlds/default.cfg

# Start the Half-Life Dedicated Server
./hlds_run -game valve +exec default.cfg "$@"
