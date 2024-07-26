#!/bin/bash

# Reassemble the parts into a single file
echo "Reassembling the parts..."
cat vzdump-qemu-105-2024_07_25-19_42_45.vma.zst.part* > "reassembled_vzdump-qemu-105-2024_07_25-19_42_45.vma.zst"

# List the reassembled file to verify
echo "Reassembled file:"
ls -lh "reassembled_vzdump-qemu-105-2024_07_25-19_42_45.vma.zst"

# Generate checksums for the reassembled file
echo "Generating checksum for the reassembled file..."
shasum -a 256 "reassembled_vzdump-qemu-105-2024_07_25-19_42_45.vma.zst" > reassembled_checksum.txt

# Compare the checksums
echo "Comparing checksums..."
if diff original_checksum.txt reassembled_checksum.txt > /dev/null; then
  echo "Checksum verification passed. The files are identical."
else
  echo "Checksum verification failed. The files are not identical."
fi

# Clean up the checksum files
echo "Cleaning up..."
rm reassembled_checksum.txt

echo "Done."
