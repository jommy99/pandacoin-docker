#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for pandacoind"

  set -- pandacoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "pandacoind" ]; then
  mkdir -p "$PANDACOIN_DATA"
  chmod 700 "$PANDACOIN_DATA"
  chown -R pandacoin "$PANDACOIN_DATA"

  echo "$0: setting data directory to $PANDACOIN_DATA"

  set -- "$@" -datadir="$PANDACOIN_DATA"
fi

if [ "$1" = "pandacoind" ]; then
  echo
  exec gosu pandacoin "$@"
fi

echo
exec "$@"
