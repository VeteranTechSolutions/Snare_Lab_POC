#!/bin/bash

LOGFILE=~/Git_Project/Snare_Lab_POC/setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

# Define the directories and file paths
TEMP_DIR="drivers.tmp"
FINAL_DIR=~/Git_Project/Snare_Lab_POC/packer/win11/drivers
VIRTIO_ISO_PATH=~/Git_Project/Snare_Lab_POC/ansible/images/virtio-win.iso
SPICE_TOOLS_URL="https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-0.141/spice-guest-tools-0.141.exe"

# Prepare drivers and tools
prepare_drivers() {
  # Remove the temporary directory if it exists
  rm -rf "$TEMP_DIR"

  # Create the final directory
  mkdir -p "$FINAL_DIR"

  # Extract the ISO contents
  log "Extracting VirtIO drivers..."
  7z x -o"$TEMP_DIR" "$VIRTIO_ISO_PATH"

  # Download the SPICE Guest Tools
  log "Downloading SPICE Guest Tools..."
  wget -O "$TEMP_DIR/spice-guest-tools.exe" "$SPICE_TOOLS_URL"

  # Move extracted contents to the final directory
  mv "$TEMP_DIR"/* "$FINAL_DIR"

  # Clean up temporary directory
  rm -rf "$TEMP_DIR"

  log "Drivers and tools have been successfully prepared in the '$FINAL_DIR' directory."
}

# Define the next script variables
NEXT_SCRIPT="task_terraforming.sh"
NEXT_SCRIPT_DIR=~/Git_Project/Snare_Lab_POC/terraform

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT $NEXT_SCRIPT"
  cd "$NEXT_SCRIPT_DIR" || error_exit "Failed to change directory to $NEXT_SCRIPT_DIR"
  ./"$NEXT_SCRIPT"
}

# Run the preparation function
prepare_drivers

# Run the next script
run_next_script
