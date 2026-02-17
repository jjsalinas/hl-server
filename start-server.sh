#!/bin/bash

# Apply environment variables to server.cfg
if [ -n "$SERVER_NAME" ]; then
    sed -i "s/^hostname.*/hostname \"$SERVER_NAME\"/" /opt/steam/hlds/valve/server.cfg
fi

if [ -n "$MAX_PLAYERS" ]; then
    sed -i "s/^maxplayers.*/maxplayers $MAX_PLAYERS/" /opt/steam/hlds/valve/server.cfg
fi

if [ -n "$SERVER_PASSWORD" ]; then
    sed -i "s/^sv_password.*/sv_password \"$SERVER_PASSWORD\"/" /opt/steam/hlds/valve/server.cfg
fi

if [ -n "$RCON_PASSWORD" ]; then
    sed -i "s/^rcon_password.*/rcon_password \"$RCON_PASSWORD\"/" /opt/steam/hlds/valve/server.cfg
fi

# Update MOTD with custom welcome message
if [ -n "$WELCOME_MESSAGE" ]; then
    sed -i "s/WELCOME TO THE SERVER!/$WELCOME_MESSAGE/" /opt/steam/hlds/valve/motd.txt
fi

# Start the Half-Life server on crossfire map
cd /opt/steam/hlds
./hlds_run \
    -game valve \
    +maxplayers ${MAX_PLAYERS:-16} \
    +map crossfire \
    -port 27015 \
    +sv_lan 0 \
    +exec server.cfg
