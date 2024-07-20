#!/bin/bash

# Navigate to the project root directory
cd $(dirname $0)
cd ..

# Activate the virtual environment
if [ -d "venv" ]; then
  source venv/bin/activate
else
  echo "Virtual environment not found. Please run the setup script to create it."
  exit 1
fi

# Call the create_venv.sh script
./Setup/create_venv.sh
