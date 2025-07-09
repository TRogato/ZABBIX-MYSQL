Zabbix Server Installation Script for Ubuntu Server 24.04 LTS
This script automates the installation and configuration of Zabbix Server 7.0 on Ubuntu Server 24.04 LTS. Zabbix is an open-source monitoring tool for tracking IT components such as networks, servers, virtual machines, and cloud services. It provides metrics like network bandwidth usage, CPU load, and disk space consumption, along with alerting capabilities.
Prerequisites
Before running the script, ensure the following requirements are met:

Operating System: Ubuntu Server 24.04 LTS x64
Kernel Version: >= 6.8
User Privileges: Script must be run as root (use sudo -i)
Dependencies: The following packages must be installed:
mariadb-server
mariadb-common
apache2
php


Internet Connection: Required for downloading the Zabbix repository and packages.
LAMP Stack: It is recommended to have a LAMP (Linux, Apache, MariaDB, PHP) stack pre-installed. You can use a lamp.sh script to set this up if needed.

To install dependencies manually, run:
sudo apt install mariadb-server mariadb-common apache2 php

Script Overview

File: zabbix.sh
Version: 0.05
Last Updated: 09/07/2025
Purpose: Installs and configures Zabbix Server 7.0, including the database, frontend, and agent, on Ubuntu Server 24.04 LTS.
Log Output: Logs are saved to /var/log/zabbix.sh.

Installation Steps

Download the Script:Ensure the zabbix.sh script is available on your system. You can copy it to your server or download it from the repository.

Set Execute Permissions:
chmod +x zabbix.sh


Run the Script as Root:
sudo -i
./zabbix.sh


Follow Prompts:

The script checks for root privileges, Ubuntu version (24.04), and kernel (>=6.8).
It verifies dependencies and exits if any are missing, prompting you to install them.
The script will pause at certain points to allow manual editing of configuration files (/etc/zabbix/zabbix_server.conf, /etc/zabbix/apache.conf, /etc/zabbix/zabbix_agentd.conf). Press <Enter> to open these files in vim. Modify as needed or save and exit (:wq).


Script Actions:

Adds Ubuntu universe and multiverse repositories.
Updates the system and installs the Zabbix 7.0 repository.
Installs Zabbix Server, frontend, Apache configuration, and agent, along with additional tools (traceroute, nmap, snmp, snmpd, snmp-mibs-downloader).
Creates a MariaDB database (zabbix) and user (zabbix with password zabbix).
Populates the database with the Zabbix schema.
Configures and restarts Zabbix services and Apache.
Verifies listening ports (10050 and 10051).



Post-Installation Configuration
After the script completes, configure Zabbix via the web interface:

Access the Web Interface:Open a browser and navigate to:
http://<server-ip>/zabbix/

Replace <server-ip> with your server's IP address (displayed during script execution).

Web Configuration Steps:Follow the on-screen instructions:

Welcome to Zabbix 7.0: Select language (default: English) and click Next step.
Check of pre-requisites: Ensure all checks pass, then click Next step.
Configure DB connection:
Database type: MariaDB
Database host: localhost
Database port: 0 (default: 3306)
Database name: zabbix
Store credentials in: Plain text
User: zabbix
Password: zabbix
Click Next step.


Zabbix server details:
Host: localhost
Port: 10051
Name: ptispo01ws01 (or your preferred server name)
Click Next step.


GUI settings:
Default time zone: System
Default theme: Dark
Click Next step.


Pre-installation summary: Review and click Next step.
Install: Click Finish.


Login:

Default user: Admin (case-sensitive)
Default password: zabbix



Troubleshooting

Dependency Errors: If the script reports missing dependencies, install them using the suggested apt install command or a LAMP setup script.
Database Issues: Ensure MariaDB is running (`systemctl status mariertino
Port Issues: Verify ports 10050 and 10051 are open using ss -tuln.
Configuration Files: Check the backed-up originals (*.bkp) if issues arise after editing.
Service Failures: Check service status with:systemctl status zabbix-server
systemctl status zabbix-agent
systemctl status apache2



Additional Information

Official Zabbix Website: https://www.zabbix.com/
Log File: /var/log/zabbix.sh
Support: Refer to the Zabbix documentation or community forums for advanced configurations.

Author

Robson Vaamonde
Website: www.procedimentosemti.com.br
Facebook: ProcedimentosEmTI, BoraParaPratica
YouTube: BoraParaPratica
