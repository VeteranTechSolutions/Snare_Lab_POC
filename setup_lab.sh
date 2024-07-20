#!/bin/bash

# Clone the Git repository
GIT_REPO_URL="https://github.com/VeteranTechSolutions/Snare_Lab_POC.git"
REPO_DIR="Snare_Lab_POC"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Cloning the Git repository..."
if [ -d "$REPO_DIR" ]; then
  log "Repository directory already exists. Pulling the latest changes..."
  cd "$REPO_DIR" && git pull || exit 1
else
  git clone "$GIT_REPO_URL" "$REPO_DIR" || exit 1
  cd "$REPO_DIR"
fi

# Navigate to the Setup directory
cd Setup

# Make initialize_and_update.sh executable
chmod +x initialize_and_update.sh

# Run initialize_and_update.sh
./initialize_and_update.sh

# Return to the root directory
cd ..
