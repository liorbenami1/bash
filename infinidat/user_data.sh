#!/bin/bash
#
# Install Ansible and use `ansible-pull` to run the playbook for this instance.

# Some sane options.
set -e # Exit on first error.
set -x # Print expanded commands to stdout.

export log_name="/tmp/user_data_boot.log"

echo "This is an informative log" > $log_name
echo "">> $log_name
echo "This script run on bootstrap. The script will install and run flask application" > $log_name

function main {
  echo "Set our named arguments: ">> $log_name
  echo "url=$1 playbook=$2 ">> $log_name
  echo "playbook=$2 ">> $log_name
  echo "">> $log_name
  # Set our named arguments.
  declare -r url=$1 playbook=$2

  echo "Ensure the instance is up-to-date with: apt-get update -y ">> $log_name
  # Ensure the instance is up-to-date.
  sudo apt-get update -y

  echo "Install required packages with:  apt-get install git -y ">> $log_name
  # Install required packages.
  sudo apt-get install git -y

  echo "Install pip with:  apt-get install python-pip -y ">> $log_name
  # install pip
  sudo apt-get install python-pip -y

  echo "Install Ansible! We use pip as the EPEL package runs on Python 2.6 with: pip install ansible ">> $log_name
  # Install Ansible! We use pip as the EPEL package runs on Python 2.6...
  sudo pip install ansible

  echo "Download our Ansible repository and run the given playbook. ">> $log_name
  echo "Pip installs executables into a directory not in the root users PATH ">> $log_name
  echo "Going to clone the flask app to: /var/local/src/instance-bootstrap and run the playbook ">> $log_name
  # Download our Ansible repository and run the given playbook. Pip installs
  # executables into a directory not in the root users $PATH.
  sudo /usr/local/bin/ansible-pull --accept-host-key --verbose \
    --url "$url" --directory /var/local/src/instance-bootstrap "$playbook"
}

#
#
main \
  'https://github.com/liorbenami1/infinidat-task.git' \
  'my-flask-playbook.yml'
