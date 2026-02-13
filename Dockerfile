FROM debian:bullseye-slim

# Build arguments
# ARG HLDS_BUILD=7559
ARG HLDS_BUILD=7882
ARG METAMOD_VERSION=1.21p38
ARG AMXMODX_VERSION=1.8.1-300

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    lib32gcc-s1 \
    lib32stdc++6 \
    libc6-i386 \
    wget \
    curl \
    unzip \
    ca-certificates \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Create steam user and directories
RUN useradd -m steam && \
    mkdir -p /opt/steam/hlds

# Download HLDS
WORKDIR /tmp
RUN wget "https://github.com/EXORTEM/hlds/releases/download/${HLDS_BUILD}/hlds_build_${HLDS_BUILD}.zip" && \
    unzip "hlds_build_${HLDS_BUILD}.zip" && \
    mv hlds_build_${HLDS_BUILD}/* /opt/steam/hlds/ && \
    rm -rf "hlds_build_${HLDS_BUILD}.zip" "hlds_build_${HLDS_BUILD}" && \
    chmod +x /opt/steam/hlds/hlds_run && \
    chmod +x /opt/steam/hlds/hlds_linux

# Install Metamod-P
RUN mkdir -p /opt/steam/hlds/valve/addons/metamod/dlls && \
    touch /opt/steam/hlds/valve/addons/metamod/plugins.ini && \
    wget "https://github.com/Bots-United/metamod-p/releases/download/v${METAMOD_VERSION}/metamod_i686_linux_win32-${METAMOD_VERSION}.tar.xz" && \
    tar -xJf "metamod_i686_linux_win32-${METAMOD_VERSION}.tar.xz" -C /opt/steam/hlds/valve/addons/metamod/dlls && \
    rm "metamod_i686_linux_win32-${METAMOD_VERSION}.tar.xz" && \
    sed -i 's/dlls\/hl\.so/addons\/metamod\/dlls\/metamod.so/g' /opt/steam/hlds/valve/liblist.gam

# Install AMX Mod X 1.9 (stable, fixes crashes with newer HLDS)
RUN wget "https://www.amxmodx.org/latest.php?version=1.9&os=linux&package=base" -O amxmodx-base.tar.gz && \
    tar -xzf amxmodx-base.tar.gz -C /opt/steam/hlds/valve/ && \
    rm amxmodx-base.tar.gz && \
    echo 'linux addons/amxmodx/dlls/amxmodx_mm_i386.so' >> /opt/steam/hlds/valve/addons/metamod/plugins.ini

# Copy maps to AMX config
RUN cat /opt/steam/hlds/valve/mapcycle.txt >> /opt/steam/hlds/valve/addons/amxmodx/configs/maps.ini

# Copy custom configuration files
COPY server.cfg /opt/steam/hlds/valve/server.cfg
COPY mapcycle.txt /opt/steam/hlds/valve/mapcycle.txt
COPY motd.txt /opt/steam/hlds/valve/motd.txt
COPY roundstart.cfg /opt/steam/hlds/valve/roundstart.cfg

# Fix error that steamclient.so is missing
RUN mkdir -p /home/steam/.steam && \
    ln -s /opt/steam/hlds/linux32 /home/steam/.steam/sdk32

# Fix warnings for missing config files
RUN touch /opt/steam/hlds/valve/listip.cfg && \
    touch /opt/steam/hlds/valve/banned.cfg

# Create steam_appid.txt
RUN echo 70 > /opt/steam/hlds/steam_appid.txt

# Copy and setup startup script
COPY start-server.sh /start-server.sh
RUN chmod +x /start-server.sh && \
    chown steam:steam /start-server.sh

# Change ownership
RUN chown -R steam:steam /opt/steam

# Switch to steam user
USER steam

# Set working directory
WORKDIR /opt/steam/hlds

# Expose ports
EXPOSE 27015/tcp 27015/udp

# Set entrypoint
ENTRYPOINT ["/start-server.sh"]
