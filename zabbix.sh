#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 25/07/2020
# Data de atualização: 09/07/2025
# Versão: 0.05
# Testado e homologado para a versão do Ubuntu Server 24.04.x LTS x64
# Kernel >= 6.8.x
# Testado e homologado para a versão do Zabbix 7.0.x
#
# O Zabbix é uma ferramenta de software de monitoramento de código aberto para diversos componentes de TI,
# incluindo redes, servidores, máquinas virtuais e serviços em nuvem. O Zabbix fornece métricas de monitoramento,
# utilização da largura de banda da rede, carga de uso CPU e consumo de espaço em disco, entre vários outros
# recursos de monitoramento e alertas.
#
# Informações que serão solicitadas na configuração via Web do Zabbix Server
# Welcome to Zabbix 7.0:
#   Default language: English (en_US): Next step;
# Check of pre-requisites: Next step;
# Configure DB connection:
#	Database type: MariaDB
#	Database host: localhost
#	Database port: 0 (use default port: 3306)
#	Database name: zabbix
#	Store credentials in: Plain text
#	User: zabbix
#	Password: zabbix: Next step;
# Zabbix server details
#	Host: localhost
#	Port: 10051
#	Name: ptispo01ws01: Next step;
# GUI settings
#	Default time zone: System
#	Default theme: Dark: Next step;
# Pre-installation summary: Next step.
# Install: Finish
# User Default: Admin (com A maiúsculo)
# Password Default: zabbix
#
# Site Oficial do Projeto: https://www.zabbix.com/
#
# Variável da Data Inicial para calcular o tempo de execução do script
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário é "root", versão do Ubuntu e kernel
# opções do comando id: -u (user)
# opções do comando lsb_release: -rs (release, short)
# opções do comando uname: -r (kernel release)
# opções do comando cut: -d (delimiter), -f (fields)
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
KERNEL=$(uname -r | cut -d'.' -f1,2)
#
# Variável do caminho do Log do Script
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Declarando as variáveis para criação da Base de Dados do Zabbix Server
USER="root"
PASSWORD="pti@2018"
#
# opção do comando create: create (criação), database (base de dados), character set (conjunto de caracteres),
# collate (comparar)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - senha do usuário)
# opção do comando grant: grant (permissão), usage (uso em), *.* (todos os bancos/tabelas), to (para)
# opção do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na), *.* (todos os bancos/tabelas)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
DATABASE="CREATE DATABASE zabbix character set utf8mb4 collate utf8mb4_bin;"
CREATETABLE="/usr/share/zabbix-sql-scripts/mysql/server.sql.gz"
USERDATABASE="CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';"
GRANTDATABASE="GRANT USAGE ON *.* TO 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';"
GRANTALL="GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
FLUSH="FLUSH PRIVILEGES;"
#
# Declarando as variáveis para o download do Zabbix Server (Link atualizado em 09/07/2025)
ZABBIX="https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu24.04_all.deb"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração
export DEBIAN_FRONTEND="noninteractive"
#
# Verificando se o usuário é Root, Distribuição é 24.04 e o Kernel é >=6.8
clear
if [ "$USUARIO" == "0" ] && [ "$UBUNTU" == "24.04" ] && [ "$KERNEL" == "6.8" ]
	then
		echo -e "O usuário é Root, continuando com o script..."
		echo -e "Distribuição é 24.04.x, continuando com o script..."
		echo -e "Kernel é >= 6.8, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não é Root ($USUARIO) ou Distribuição não é 24.04.x ($UBUNTU) ou Kernel não é >=6.8 ($KERNEL)"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
# Verificando se as dependências do Zabbix estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND
echo -n "Verificando as dependências do Zabbix, aguarde... "
	for name in mariadb-server mariadb-common apache2 php
	do
		[[ $(dpkg -s $name 2> /dev/null) ]] || {
			echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
			deps=1;
		}
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || {
			echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo utilizar o script: lamp.sh para resolver as dependências."
			exit 1;
		}
		sleep 5
#
# Script de instalação do Zabbix Server no GNU/Linux Ubuntu Server 24.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
#
clear
echo
echo -e "Instalação do Zabbix Server no GNU/Linux Ubuntu Server 24.04.x\n"
echo -e "Após a instalação do Zabbix Server acesse a URL: http://$(hostname -I | cut -d' ' -f1)/zabbix/"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o Repositório Multiversão do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository multiverse &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Zabbix Server, aguarde...\n"
#
echo -e "Fazendo o download e instalando o Repositório do Zabbix Server, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando wget: -O (output document file)
	# opção do comando rm: -v (verbose)
	# opção do comando dpkg: -i (install)
	rm -v zabbix.deb &>> $LOG
	wget $ZABBIX -O zabbix.deb &>> $LOG
	dpkg -i zabbix.deb &>> $LOG
echo -e "Repositório instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt com o novo Repositório do Zabbix Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Zabbix Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent \
	traceroute nmap snmp snmpd snmp-mibs-downloader &>> $LOG
echo -e "Zabbix Server instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Banco de Dados e Populando as Tabelas do Zabbix Server, aguarde esse processo demora um pouco..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando mariadb: -u (user), -p (password), -e (execute)
	# opção do comando zcat: -v (verbose)
	mariadb -u $USER -p$PASSWORD -e "$DATABASE" &>> $LOG
	mariadb -u $USER -p$PASSWORD -e "$USERDATABASE" &>> $LOG
	mariadb -u $USER -p$PASSWORD -e "$GRANTDATABASE" &>> $LOG
	mariadb -u $USER -p$PASSWORD -e "$GRANTALL" &>> $LOG
	mariadb -u $USER -p$PASSWORD -e "$FLUSH" &>> $LOG
	zcat -v $CREATETABLE | mariadb -uzabbix -pzabbix zabbix &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração da Base de Dados do Zabbix Server, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	read
	cp -v /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.bkp &>> $LOG
	vim /etc/zabbix/zabbix_server.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do PHP do Zabbix Server, pressione <Enter> for continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	read
	cp -v /etc/zabbix/apache.conf /etc/zabbix/apache.conf.bkp &>> $LOG
	vim /etc/zabbix/apache.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Zabbix Agent, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	read
	cp -v /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.bkp &>> $LOG
	vim /etc/zabbix/zabbix_agentd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando os serviços do Zabbix Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable zabbix-server zabbix-agent &>> $LOG
	systemctl restart zabbix-server zabbix-agent apache2 &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexões do Zabbix Server, aguarde..."
	# opção do comando ss: -t (tcp), -n (numeric), -l (listening)
	# opção do comando grep: -i (ignore case), \| (função OU)
	ss -tuln | grep -i '10050\|10051'
echo -e "Portas verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Zabbix Server feita com Sucesso!!!."
	# script para calcular o tempo gasto
	# opção do comando date: +%T (Time)
	HORAFINAL=$(date +%T)
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute Germania
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
read
exit 0
