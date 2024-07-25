#!/bin/bash

# Reassemble the parts into a single file
echo "Reassembling the parts..."
cat windows_server_2019.iso.part* > "windows_server_2019.iso"

# List the reassembled file to verify
echo "Reassembled file:"
ls -lh "windows_server_2019.iso"

# Generate checksums for the reassembled file
echo "Generating checksum for the reassembled file..."
shasum -a 256 "windows_server_2019.iso" > reassembled_checksum.txt

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

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT reassemble_windows10.iso.sh"
  cd ~/Git_Project/Snare_Lab_POC/ansible/images/snare_central_ISO/
  ./reassemble_Snare_Central.iso.sh
}

run_next_script
