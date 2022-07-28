# This is a practice script, and it's not yet tested. Approach carefully !!!

---

We are looking for someone that is good at writing Bash scripts and has experience working in Amazon Web Services to help on a small project.

Context:
A) All new (latest) Amazon Machine Images released from AWS include a Systems Manager agent pre-installed.

B) We have a use-case, where several linux systems were imaged a few years ago. We tend to spin these systems up for random projects/use-cases. These systems DO NOT have the systems manager agent pre-installed.

C) We would like a bash script that detects the operating system (what type of linux?) once detected, check if the Systems Manager agent is running/installed. If not, install - per requirements for that flavor of linux.. Also check if Amazon Inspector agent is installed, if not, install this as well in the same manner.

We need to support the following versions of Linux:
- Amazon Linux (v1)
- Amazon Linux 2
- CentOS
- CentOS Stream
- Debian Server
- Oracle Linux
- Red Hat Enterprise Linux
- Rocky Linux
- SUSE Linux Enterprise Server
- Ubuntu Server

References:

[Systems Manager agent instructions:](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-manual-agent-install.html)

[Amazon Inspector Agent (v1):](https://docs.aws.amazon.com/inspector/v1/userguide/inspector_installing-uninstalling-agents.html#install-linux)

Script flow:
- Detect Linux OS/version
- Per Linux OS/version, run command to check if Systems Manager & Inspector agents are installed/running. If not, install agents.
- If agents installed, all is good - exit successfully.