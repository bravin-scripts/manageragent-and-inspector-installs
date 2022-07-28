#!/bin/bash

# get os version
osversion=$(hostnamectl | grep "Operating System")

echo "$osversion"

# Per Linux OS/version, run command to check if Systems Manager & Inspector agents are installed/running.
# If not, install agents.

function ssm_agent_checks {
     amazon_ssm_agent_status=$(sudo systemctl status amazon-ssm-agent | egrep -o 'running|dead')
    if [[ amazon_ssm_agent_status == 'running' ]]; then
        echo "amazon-ssm-agent is currently running."
    elif [[ amazon_ssm_agent_status == "dead" ]]; then
        echo "amazon-ssm-agent is inactive (dead). Booting it up."
        sudo systemctl start amazon-ssm-agent
        sleep 5 # wait for 5 seconds <- refer later in code
        new_state_from_dead_ssmagent=$(sudo systemctl status amazon-ssm-agent | egrep -o 'running|dead')
        echo "Servise status $new_state_from_dead_ssmagent"
    else
        install_ssm_agent_per_os=true
        echo "Proceeding to install amazon-ssm-agent ...."
    fi
}

function inspector_agents_checks {
    amazon_inspector_agent_status=$(sudo systemctl status awsagent | egrep -o 'running|dead')
    if [[ "$amazon_inspector_agent_status" == 'running' ]]; then
        echo "Amazon Inspector Classic agent is running."
    elif [[ "$amazon_inspector_agent_status" == "dead" ]]; then
        echo "Amazon Inspector Classic agent is inactice. Proceeding to boot it up...."
        sudo /etc/init.d/awsagent start
    else
        wget https://inspector-agent.amazonaws.com/linux/latest/install
        sudo bash install
        sudo /etc/init.d/awsagent start
}

function enable_and_start {
    sleep 2
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
    agent_state_after_install=$(sudo systemctl status amazon-ssm-agent | egrep -o 'running|dead')
    echo "Servise status: $agent_state_after_install"
}

case $osversion in 

    # Amazon Linux (V1) and Amazon Linux 2
    *"Amazon Linux"*)
    ssm_agent_checks
    if [[ "$install_ssm_agent_per_os" == true ]]; then
        sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm
        enable_and_start
    fi
    inspector_agents_checks
    ;;

    *"CentOS"*) # CentOS and CentOS Stream
    ssm_agent_checks
    if [[ "$install_ssm_agent_per_os" == true ]]; then
        sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm
        enable_and_start
    fi
    inspector_agents_checks
    ;;

    *"Debian Server"*) # Debian Server
    ssm_agent_checks
    if [[ "$install_ssm_agent_per_os" == true ]]; then
        mkdir /tmp/ssm
        cd /tmp/ssm
        wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_arm64/amazon-ssm-agent.deb
        sudo dpkg -i amazon-ssm-agent.deb
        enable_and_start
    fi
    inspector_agents_checks
    ;;

    *"Oracle Linux"*) # Oracle Linux
    ssm_agent_checks
    if [[ "$install_ssm_agent_per_os" == true ]]; then
        sudo yum install -y https://s3.us-east-1.amazonaws.com/amazon-ssm-us-east-1/latest/linux_amd64/amazon-ssm-agent.rpm
        enable_and_start
    fi
    inspector_agents_checks
    ;;

    *"Red Hat Enterprise Linux"*) # Red Hat Enterprise Linux
    ssm_agent_checks
    if [[ "$install_ssm_agent_per_os" == true ]]; then
        sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm
        enable_and_start
    fi
    inspector_agents_checks
    ;;

    *"Rocky Linux"*) # Rocky Linux
    ssm_agent_checks
    if [[ "$install_ssm_agent_per_os" == true ]]; then
        sudo dnf install -y https://s3.us-east-1.amazonaws.com/amazon-ssm-us-east-1/latest/linux_arm64/amazon-ssm-agent.rpm
        enable_and_start
    fi
    inspector_agents_checks
    ;;

    *"SUSE Linux Enterprise Server"*) # SUSE Linux Enterprise Server
    ssm_agent_checks
    if [[ "$install_ssm_agent_per_os" == true ]]; then
        mkdir /tmp/ssm
        cd /tmp/ssm
        wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm
        sudo rpm --install amazon-ssm-agent.rpm
        enable_and_start
    fi
    inspector_agents_checks
    ;;

    *"Ubuntu Server"*) # Ubuntu Server
    ssm_agent_checks
    if [[ "$install_ssm_agent_per_os" == true ]]; then
        sudo snap install amazon-ssm-agent --classic
        enable_and_start
    fi
    inspector_agents_checks
    ;;
esac