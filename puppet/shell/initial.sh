#!/bin/sh

VAGRANT_CORE_FOLDER=$(echo "$1")

if [[ ! -d /.puppet-stuff ]]; then
    mkdir /.puppet-stuff

    cat "${VAGRANT_CORE_FOLDER}/puppet/shell/self-promotion.txt"
    echo "Created directory /.puppet-stuff"
fi

if [[ ! -f /.puppet-stuff/initial-setup-repo-update ]]; then
    echo "Running initial-setup yum update"
    yum install yum-plugin-fastestmirror -y >/dev/null
    yum check-update -y >/dev/null
    echo "Finished running initial-setup yum update"

    echo "Installing basic development tools (CentOS)"
    yum -y groupinstall "Development Tools" >/dev/null
    echo "Finished installing basic development tools (CentOS)"
    touch /.puppet-stuff/initial-setup-repo-update
fi
