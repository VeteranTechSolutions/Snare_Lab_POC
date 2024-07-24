#!/bin/bash

LOGFILE=setup.log
PROJECT_ROOT=$(pwd)

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

prepare_project() {
  log "Making project scripts executable..."
  chmod +x create_venv.sh
  chmod +x source_venv.sh
  chmod +x Setup/update_system_and_install_dependencies.sh
  chmod +x Setup/configure_user_and_replace_placeholders.sh
  chmod +x Setup/download_iso_files.sh
  chmod +x Setup/download_snare_files.sh
  chmod +x Setup/install_automation_tools.sh
  chmod +x Setup/reassemble_iso_files.sh
 #chmod +x Setup/upload_iso.sh 

  log "Running create_venv.sh..."
  source ./create_venv.sh

