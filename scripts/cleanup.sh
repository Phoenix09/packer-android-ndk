#!/bin/sh
set -e
echo "Removing unneeded packages..."
apt-get autoremove --purge

printf "Cleaning APT package cache... "
apt-get clean
echo "done."

printf "Cleaning /tmp... "
rm -rf /tmp/*
echo "done"

echo "Zeroing free space..."
dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

SWAP_UUID="$(blkid -l -o value -s UUID -t TYPE=swap || true)"
if [ -n "$SWAP_UUID" ]; then
	echo "Zeroing swap..."
	SWAP_DEV="$(realpath "/dev/disk/by-uuid/$SWAP_UUID")"
	swapoff -a
	dd if=/dev/zero of="$SWAP_DEV" bs=1M || true
	mkswap -f -U "$SWAP_UUID" "$SWAP_DEV"
fi

SWAP_FILE="$(awk '$2 == "file" { print $1 }' /proc/swaps)"
if [ -n "$SWAP_FILE" ]; then
	echo "Zeroing swap file..."
	swapoff "$SWAP_FILE"
	SWAP_SIZE="$(stat --printf='%s' "$SWAP_FILE")"
	BS=1
	if [ "$(($SWAP_SIZE%1048576))" = "0" ]; then
		BS=1M
		SWAP_SIZE="$(($SWAP_SIZE/1048576))"
	elif [ "$(($SWAP_SIZE%524288))" = "0" ]; then
		BS=512K
		SWAP_SIZE="$(($SWAP_SIZE/524288))"
	elif [ "$(($SWAP_SIZE%512))" = "0" ]; then
		BS=512
		SWAP_SIZE="$(($SWAP_SIZE/512))"
	fi
	dd if=/dev/zero of="$SWAP_FILE" bs="$BS" count="$SWAP_SIZE" || true
	mkswap -f "$SWAP_FILE"
fi

exit 0
