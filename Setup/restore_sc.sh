#!/bin/bash

# Variables
BACKUP_FILE="/var/lib/vz/dump/vzdump-qemu-106-2024_07_17-10_57_18.vma.zst"
STORAGE_NAME="local-zfs"

# Function to find the next available VM ID
get_next_vm_id() {
    local max_id=$(qm list | awk 'NR>1 {print $1}' | sort -n | tail -1)
    if [[ -z "$max_id" ]]; then
        next_id=100
    else
        next_id=$((max_id + 1))
    fi
    echo $next_id
}

# Find the next available VM ID
NEXT_VM_ID=$(get_next_vm_id)
echo "Next available VM ID is: $NEXT_VM_ID"

# Restore the VM
qmrestore $BACKUP_FILE $NEXT_VM_ID --storage $STORAGE_NAME

# Check if the restore was successful
if [[ $? -eq 0 ]]; then
    echo "VM restored successfully with ID $NEXT_VM_ID."
else
    echo "Failed to restore VM."
fi
