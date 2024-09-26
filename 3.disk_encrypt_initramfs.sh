#!/bin/sh

e2fsck -f /dev/sda2
resize2fs -fM /dev/sda2

BLOCK_COUNT="$(dumpe2fs /dev/sda2 | sed "s/ //g" | sed -n "/Blockcount:/p" | cut -d ":" -f 2)"
echo "Block count: $BLOCK_COUNT"
SHA1SUM_ROOT="$(dd bs=4k count=$BLOCK_COUNT if=/dev/sda2 | sha1sum)"
dd bs=4k count=$BLOCK_COUNT if=/dev/sda2 of=/dev/sdb
SHA1SUM_EXT="$(dd bs=4k count=$BLOCK_COUNT if=/dev/sdb | sha1sum)"

if [ "$SHA1SUM_ROOT" == "$SHA1SUM_EXT" ]; then
	echo "1.Sha1sums match."
	cryptsetup --cipher aes-cbc-essiv:sha256 luksFormat /dev/sda2
	cryptsetup luksOpen /dev/sda2 sdcard
	dd bs=4k count=$BLOCK_COUNT if=/dev/sdb of=/dev/mapper/sdcard
	SHA1SUM_NEWROOT="$(dd bs=4k count=1516179 if=/dev/mapper/sdcard | sha1sum)"
	if [ "$SHA1SUM_ROOT" == "$SHA1SUM_EXT" ]; then
		echo "2.Sha1sums match."
		e2fsck -f /dev/mapper/sdcard
		resize2fs -f /dev/mapper/sdcard
		echo "Done. Reboot and rebuild initramfs."
	else
		echo "2.Sha1sums error."
	fi
else
	echo "1.Sha1sums error."
fi
