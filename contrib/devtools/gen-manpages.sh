#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

WOOCOIND=${WOOCOIND:-$SRCDIR/woocoind}
WOOCOINCLI=${WOOCOINCLI:-$SRCDIR/woocoin-cli}
WOOCOINTX=${WOOCOINTX:-$SRCDIR/woocoin-tx}
WOOCOINQT=${WOOCOINQT:-$SRCDIR/qt/woocoin-qt}

[ ! -x $WOOCOIND ] && echo "$WOOCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
WOOVER=($($WOOCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$WOOCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $WOOCOIND $WOOCOINCLI $WOOCOINTX $WOOCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${WOOVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${WOOVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
