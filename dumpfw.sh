#!/bin/sh

# Set your SD card mount point here:
SDCARD_PATH="/tmp/sdcard"
DUMP_DIR="$SDCARD_PATH/flash_dump"
mkdir -p "$DUMP_DIR"

echo "[*] Dumping MTD partitions to $DUMP_DIR"

cat /proc/mtd | while read line; do
  case "$line" in
    mtd*)
      devname=$(echo $line | cut -d: -f1)      # e.g. mtd0
      partname=$(echo $line | cut -d\" -f2)    # e.g. "K"
      dumpfile="$DUMP_DIR/$partname.bin"

      echo "[*] Dumping /dev/$devname to $dumpfile"
      cat /dev/$devname > "$dumpfile"

      if [ $? -eq 0 ]; then
        echo "    [+] Done: $partname"
      else
        echo "    [!] Failed to dump $partname"
      fi
      ;;
  esac
done

echo "[✓] All available MTD partitions dumped."
