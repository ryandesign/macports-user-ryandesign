#!/bin/bash

# This script runs the game launcher (if it's already been installed)
# or the installer (if it hasn't).

export PREFIX="@PREFIX@"
export WINEPREFIX="@WINEPREFIX@"

function cleanup {
    "$PREFIX/bin/wineserver" -k &
    exit 0
}

trap cleanup SIGHUP SIGINT SIGTERM

USER=$(id -u)
GROUP=$(id -g)

#if [ "$(stat -f '%u %g' "$WINEPREFIX")" != "$USER $GROUP" ]; then
    "@LIBEXEC@/chown-data" "$USER:$GROUP"
#fi

LAUNCHER="@LAUNCHER@"
INSTALLER="@INSTALLER@"
if [ -r "$LAUNCHER" ]; then
    PROGRAM="$LAUNCHER"
else
    PROGRAM="$INSTALLER"
fi

"$PREFIX/bin/wine" "$PROGRAM" &
sleep 5

# If we're running the installer, the installer will run the launcher
# after it's done. Wait for all apps to exit before exiting this script.
#"$PREFIX/bin/wineserver" -w
SOCKET="$(printf "/tmp/.wine-$USER/server-%x-%x/socket" $(stat -f '%d %i' "$WINEPREFIX"))"
while [ -r "$SOCKET" ]; do
    sleep 1
done
