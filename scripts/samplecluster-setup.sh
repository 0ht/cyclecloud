#!/bin/bash

echo "Installing git..."
sudo yum install -y git || { echo "Failed to install git"; exit 1; }

echo "Creating cyclecloud_projects directory..."
if [ -d ~/cyclecloud_projects ]; then
    echo "Directory already exists"
else
    mkdir cyclecloud_projects || { echo "Failed to create directory"; exit 1; }
fi

cd ~/cyclecloud_projects/
if [ -d ~/cyclecloud_projects/cyclecloud-pbspro ]; then
    echo "Repository already exists"
else
    git clone https://github.com/Azure/cyclecloud-pbspro.git || { echo "Failed to clone repository"; exit 1; }
fi

cd ~/cyclecloud_projects/cyclecloud-pbspro/templates
if [ -f ~/cyclecloud_projects/cyclecloud-pbspro/templates/openpbs_hpc.txt ]; then
    echo "Template file already exists"
else
    wget https://raw.githubusercontent.com/0ht/cyclecloud/main/scripts/openpbs_hpc.txt || { echo "Failed to get template file"; exit 1; }
fi

if [ -d ~/cyclecloud_projects/cyclecloud-pbspro/blobs ]; then
    echo "Blob directory already exists"
else
    mkdir ~/cyclecloud_projects/cyclecloud-pbspro/blobs || { echo "Failed to create blob directory"; exit 1; }
fi

cd ~/cyclecloud_projects/cyclecloud-pbspro/blobs

if [ $(ls -lA | wc -l) -le 13 ]
then
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/cyclecloud-pbspro-pkg-2.0.24.tar.gz
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/cyclecloud_api-8.3.1-py2.py3-none-any.whl
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/hwloc-libs-1.11.9-3.el8.x86_64.rpm
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/openpbs-client-20.0.1-0.x86_64.rpm
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/openpbs-client-22.05.11-0.x86_64.rpm
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/openpbs-execution-20.0.1-0.x86_64.rpm
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/openpbs-execution-22.05.11-0.x86_64.rpm
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/openpbs-server-20.0.1-0.x86_64.rpm
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/openpbs-server-22.05.11-0.x86_64.rpm
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/pbspro-client-18.1.4-0.x86_64.rpm
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/pbspro-debuginfo-18.1.4-0.x86_64.rpm
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/pbspro-execution-18.1.4-0.x86_64.rpm
wget https://github.com/Azure/cyclecloud-pbspro/releases/download/2.0.24/pbspro-server-18.1.4-0.x86_64.rpm
else
    echo "files seem to be exists."
fi

sudo chmod +x /usr/local/cyclecloud-cli/embedded/bin/azcopy
