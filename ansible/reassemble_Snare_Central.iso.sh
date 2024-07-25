#!/bin/bash

# Define the part prefix and the reassembled file name
PART_PREFIX="Snare_Central.vma.zst.part"
REASSEMBLED_FILE="Snare_Central.vma.zst"

# Reassemble the parts into a single file
echo "Reassembling the parts..."
cat ${PART_PREFIX}* > "$REASSEMBLED_FILE"

# List the reassembled file to verify
echo "Reassembled file:"
ls -lh "$REASSEMBLED_FILE"

# Generate checksums for the reassembled file
echo "Generating checksum for the reassembled file..."
shasum -a 256 "$REASSEMBLED_FILE" > reassembled_checksum.txt

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
