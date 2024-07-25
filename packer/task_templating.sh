#!/bin/bash
START_PATH=$(pwd)

create_templates(){

    for directory in $(ls -d */); do
        cd $directory
        packer init .
        echo "[+] building template in: $(pwd)"
        packer build .
        cd ..
    done;
    
}

#run_next_script() {
#  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT task_terraforming.sh"
#  cd ~/Git_Project/Snare_Lab_POC/terraform
#  ./task_terraforming.sh
#}


create_templates
#run_next_script


echo "[+] run the task_terraforming.sh in terraform/"
