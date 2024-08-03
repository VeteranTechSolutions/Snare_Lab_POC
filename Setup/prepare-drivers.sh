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
FINAL_DIR=~/Git_Project/Snare_Lab_POC/packer/drivers
VIRTIO_ISO_PATH=~/Git_Project/Snare_Lab_POC/ansible/images/virtio-win.iso
SPICE_TOOLS_URL="https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-0.141/spice-guest-tools-0.141.exe"

# Prepare drivers and tools
prepare_drivers() {

  # Create the final directory
  mkdir -p "$FINAL_DIR"

  # Extract the ISO contents
  log "Extracting VirtIO drivers..."
  7z x -o"$FINAL_DIR" "$VIRTIO_ISO_PATH"

  # Download the SPICE Guest Tools
  log "Downloading SPICE Guest Tools..."
  wget -O "$FINAL_DIR/spice-guest-tools.exe" "$SPICE_TOOLS_URL"
}

# Define the next script variables
NEXT_SCRIPT="task_templating.sh"
NEXT_SCRIPT_DIR=~/Git_Project/Snare_Lab_POC/packer

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT $NEXT_SCRIPT"
  cd "$NEXT_SCRIPT_DIR" || error_exit "Failed to change directory to $NEXT_SCRIPT_DIR"
  ./"$NEXT_SCRIPT"
}

# Run the preparation function
prepare_drivers
run_next_script


# Run the next script
run_next_script
