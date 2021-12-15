#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 10/10/2021
# Data de atualização: 15/12/2021
# Versão: 0.26
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
#
# Parâmetros (variáveis de ambiente) utilizados nos scripts de instalação dos Serviços de Rede
# no Ubuntu Server 20.04.x LTS, antes de modificar esse arquivo, veja os arquivos: BUGS, NEW e
# CHANGELOG para mais informações.
#
#=============================================================================================
#                    VARIÁVEIS GLOBAIS UTILIZADAS EM TODOS OS SCRIPTS                        #
#=============================================================================================
#
# Declarando as variáveis utilizadas na verificação e validação da versão do Ubuntu Server 
#
# Variável da Hora Inicial do Script, utilizada para calcular o tempo de execução do script
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário é "Root" e versão do "Ubuntu"
# opções do comando id: -u (user)
# opções do comando: lsb_release: -r (release), -s (short), 
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
#
# Variável do Caminho e Nome do arquivo de Log utilizado em todos os script
# $0 (variável de ambiente do nome do comando/script executado)
# opção do redirecionador | piper: Conecta a saída padrão com a entrada padrão de outro comando
# opções do comando cut: -d (delimiter), -f (fields)
LOGSCRIPT="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração e
# nenhuma interação durante a instalação ou atualização do sistema via Apt ou Apt-Get. Ele 
# aceita a resposta padrão para todas as perguntas.
export DEBIAN_FRONTEND="noninteractive"
#
#=============================================================================================
#              VARIÁVEIS DE REDE DO SERVIDOR UTILIZADAS EM TODOS OS SCRIPTS                  #
#=============================================================================================
#
# Declarando as variáveis utilizadas nas configurações de Rede do Servidor Ubuntu 
#
# Variável do Usuário padrão utilizado no Servidor Ubuntu desse curso
USUARIODEFAULT="vaamonde"
#
# Variável da Senha padrão utilizado no Servidor Ubuntu desse curso
SENHADEFAULT="pti@2018"
#
# Variável do Nome (Hostname) do Servidor Ubuntu desse curso
NOMESERVER="ptispo01ws01"
#
# Variável do Nome (Hostname) FQDN (Fully Qualified Domain Name) do Servidor Ubuntu desse curso
FQDNSERVER="ptispo01ws01.pti.intra"
#
# Variável do Nome de Domínio do Servidor Ubuntu desse curso
DOMINIOSERVER="pti.intra"
#
# Variável do Endereço IPv4 principal (padrão) do Servidor Ubuntu desse curso
IPV4SERVER="172.16.1.20"
#
# Variável do arquivo de configuração da Placa de Rede do Netplan do Servidor Ubuntu
# CUIDADO!!! o nome do arquivo de configuração da placa de rede pode mudar dependendo da 
# versão do Ubuntu Server, verificar o conteúdo do diretório: /etc/netplan para saber o nome 
# do arquivo de configuração do Netplan e mudar a variável NETPLAN com o nome correspondente.
NETPLAN="/etc/netplan/00-installer-config.yaml"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 01-openssh.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede OpenSSH utilizados nesse script
# 01. /etc/ssh/sshd_config = arquivo de configuração do Servidor OpenSSH
# 02. /etc/hostname = arquivo de configuração do Nome FQDN do Servidor
# 03. /etc/hosts = arquivo de configuração da pesquisa estática para nomes de host local
# 04. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço de rede
# 05. /etc/hosts.deny = arquivo de configuração de negação de hosts por serviço de rede
# 06. /etc/issue.net = arquivo de configuração do Banner utilizado pelo OpenSSH no login
# 07. /etc/nsswitch.conf = arquivo de configuração do switch de serviço de nomes de serviço
# 08. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
#
# Arquivos de monitoramento (log) do Serviço de Rede OpenSSH Server utilizados nesse script
# 01. systemctl status ssh = status do serviço do OpenSSH
# 02. journalctl -t sshd = todas as mensagens referente ao serviço do OpenSSH
# 03. tail -f /var/log/syslog | grep sshd = filtrando as mensagens do serviço do OpenSSH
# 04. tail -f /var/log/auth.log | grep ssh = filtrando as mensagens de autenticação do OpenSSH
# 05. tail -f /var/log/tcpwrappers-allow-ssh.log = filtrando as conexões permitidas do OpenSSH
# 06. tail -f /var/log/tcpwrappers-deny.log = filtrando as conexões negadas do OpenSSH
#
# Variável das dependências do laço de loop do OpenSSH Server
SSHDEP="openssh-server openssh-client"
#
# Variável de instalação dos softwares extras do OpenSSH Server
SSHINSTALL="net-tools ipcalc nmap tree"
#
# Variável da porta de conexão padrão do OpenSSH Server
PORTSSH="22"
#
#=============================================================================================
#                          VARIÁVEIS UTILIZADAS NO SCRIPT: 02-dhcp.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede ISC DHCP Sever utilizados nesse script
# 01. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 02. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
#
# Arquivos de monitoramento (log) do Serviço de Rede ISC DHCP Server utilizados nesse script
# 01. systemctl status isc-dhcp-server = status do serviço do ISC DHCP
# 02. journalctl -t dhcpd = todas as mensagens referente ao serviço do ISC DHCP
# 03. tail -f /var/log/syslog | grep dhcpd = filtrando as mensagens do serviço do ISC DHCP
# 04. tail -f /var/log/dmesg | grep dhcpd = filtrando as mensagens de erros do ISC DHCP
# 05. less /var/lib/dhcp/dhcpd.leases = filtrando os alugueis de endereços IPv4 do ISC DHCP
# 06. dhcp-lease-list = comando utilizado para mostrar os leases dos endereços IPv4 do ISC DHCP
#
# Variável de instalação do serviço de rede ISC DHCP Server
DHCPINSTALL="isc-dhcp-server net-tools"
#
# Variável da porta de conexão padrão do ISC DHCP Server
PORTDHCP="67"
#
#=============================================================================================
#                          VARIÁVEIS UTILIZADAS NO SCRIPT: 03-dns.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede BIND DNS Server utilizados nesse script
# 01. /etc/hostname = arquivo de configuração do Nome FQDN do Servidor
# 02. /etc/hosts = arquivo de configuração da pesquisa estática para nomes de host local
# 03. /etc/nsswitch.conf = arquivo de configuração do switch de serviço de nomes
# 04. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
# 05. /etc/bind/named.conf = arquivo de configuração da localização dos Confs do Bind9
# 06. /etc/bind/named.conf.local = arquivo de configuração das Zonas do Bind9
# 07. /etc/bind/named.conf.options = arquivo de configuração do Serviço do Bind9
# 08. /etc/bind/rndc.key = arquivo de configuração das Chaves RNDC de integração Bind9 e DHCP
# 09. /var/lib/bind/pti.intra.hosts = arquivo de configuração da Zona de Pesquisa Direta
# 10. /var/lib/bind/172.16.1.rev = arquivo de configuração da Zona de Pesquisa Inversa
# 11. /etc/cron.d/dnsupdate-cron = arquivo de configuração das atualizações de Ponteiros
# 12. /etc/default/named = arquivo de configuração do Daemon do Serviço do Bind9
#
# Arquivos de monitoramento (log) do Serviço de Rede Bind DNS Server utilizados nesse script
# 01. systemctl status bind9 = status do serviço do Bind DNS
# 02. journalctl -t named = todas as mensagens referente ao serviço do Bind DNS
# 03. tail -f /var/log/named/* = vários arquivos de Log's dos serviços do Bind DNS
#
# Declarando as variáveis de Pesquisa Direta do Domínio, Inversa e Subrede do Bind DNS Server
#
# Variável do nome do Domínio do Servidor DNS (veja a linha: 64 desse arquivo)
DOMAIN=$DOMINIOSERVER
#
# Variável do nome da Pesquisa Inversa do Servidor de DNS
DOMAINREV="1.16.172.in-addr.arpa"
#
# Variável do endereço IPv4 da Subrede do Servidor de DNS
NETWORK="172.16.1."
#
# Variável de instalação do serviço de rede Bind DNS Server
DNSINSTALL="bind9 bind9utils bind9-doc dnsutils net-tools"
#
# Variável da porta de conexão padrão do Bind DNS Server
PORTDNS="53"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 04-dhcpdns.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) da integração do Bind9 e do DHCP utilizados nesse script
# 01. tsig.key - arquivo de geração da chave TSIG de integração do Bind9 e do DHCP
# 02. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 03. /etc/bind/named.conf.local = arquivo de configuração das Zonas do Bind9
# 04. /etc/bind/rndc.key = arquivo de configuração das Chaves RNDC de integração Bind9 e DHCP
#
# Declarando a variável de geração da chave de atualização dos registros do Bind DNS Server 
# integrado no ISC DHCP Server
# 
# Variável da senha em modo texto que está configurada nos arquivos: dhcpd.conf, named.conf.local
# e rndc.key que será substituida para nova chave criptografada da variável USERUPDATE
SECRETUPDATE="vaamonde"
#
# Variável da senha utilizada na criação da chave de atualização dos ponteiros do DNS e DHCP
USERUPDATE="vaamonde"
#
# Variável das dependências do laço de loop da integração do Bind DNS e do ISC DHCP Server
DHCPDNSDEP="isc-dhcp-server bind9"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 05-ntp.sh                            #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede NTP Server utilizados nesse script
# 01. /etc/ntp.conf = arquivo de configuração do serviço de rede NTP Server
# 02. /etc/default/ntp = arquivo de configuração do Daemon do NTP Server
# 03. /var/lib/ntp/ntp.drift = arquivo de configuração do escorregamento de memória do NTP
# 04. /etc/systemd/timesyncd.conf = arquivo de configuração do sincronismo de Data e Hora
# 05. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
#
# Arquivos de monitoramento (log) do Serviço de Rede NTP Server utilizados nesse script
# 01. systemctl status ntp = status do serviço do NTP Server
# 02. journalctl -t ntpd = todas as mensagens referente ao serviço do NTP Server
# 03. tail -f /var/log/syslog | grep ntpd = vários arquivos de Log's dos serviços do NTP Server
# 04. tail -f /var/log/ntpstats/* = vários arquivos de monitoramento de tempo do NTP Server
#
# Declarando as variáveis utilizadas nas configurações do Serviço do NTP Server e Client
#
# Variável de sincronização do NTP Server com o Site ntp.br
NTPSERVER="a.st1.ntp.br"
#
# Variável do Zona de Horário do NTP Server
TIMEZONE="America/Sao_Paulo"
#
# Variável das dependências do laço de loop do NTP Server
NTPDEP="isc-dhcp-server"
#
# Variável de instalação do serviço de rede NTP Server e Client
NTPINSTALL="ntp ntpdate"
#
# Variável da porta de conexão padrão do NTP Server
PORTNTP="123"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 06-tftphpa.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede TFTP-HPA utilizados nesse script
# 01. /etc/default/tftpd-hpa = arquivo de configuração do Servidor TFTP-HPA
# 02. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 03. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
#
# Arquivos de monitoramento (log) do Serviço de Rede TFTP-HPA Server utilizados nesse script
# 01. systemctl status tftpd-hpa = status do serviço do TFTP-HPA
# 02. journalctl -t tftpd-hpa = todas as mensagens referente ao serviço do TFTP-HPA
# 03. tail -f /var/log/syslog | grep tftp = filtrando as mensagens do serviço do TFTP-HPA
# 05. tail -f /var/log/tcpwrappers-allow-tftp.log = filtrando as conexões permitidas do TFTP-HPA
# 06. tail -f /var/log/tcpwrappers-deny.log = filtrando as conexões negadas do TFTP-HPA
#
# Declarando as variáveis utilizadas nas configurações do Serviço do TFTP-HPA Server
#
# Variável de criação do diretório padrão utilizado pelo serviço do TFTP-HPA
PATHTFTP="/var/lib/tftpboot"
#
# Variável das dependências do laço de loop do TFTP-HPA Server
TFTPDEP="bind9 bind9utils isc-dhcp-server"
#
# Variável de instalação do serviço de rede TFTP-HPA Server
TFTPINSTALL="tftpd-hpa tftp-hpa"
#
# Variável da porta de conexão padrão do TFTP-HPA Server
PORTTFTP="69"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 07-lamp.sh                          #
#=============================================================================================
# 
# Arquivos de configuração (conf) do Serviço de Rede LAMP Server utilizados nesse script
# 01. /etc/apache2/apache2.conf = arquivo de configuração do Servidor Apache2
# 02. /etc/apache2/ports.conf = arquivo de configuração das portas do Servidor Apache2
# 03. /etc/apache2/sites-available/000-default.conf = arquivo de configuração do site padrão HTTP
# 04. /etc/php/7.4/apache2/php.ini = arquivo de configuração do PHP
# 05. /etc/mysql/mysql.conf.d/mysqld.cnf = arquivo de configuração do Servidor MySQL
# 06. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
# 07. /var/www/html/phpinfo.php = arquivo de geração da documentação do PHP
# 08. /var/www/html/teste.html = arquivo de teste de páginas HTML
#
# Arquivos de monitoramento (log) do Serviço de Rede LAMP Server utilizados nesse script
# 01. systemctl status apache2 = status do serviço do Apache2
# 02. journalctl -t apache2.postinst = todas as mensagens referente ao serviço do Apache2
# 03. tail -f /var/log/apache2/* = vários arquivos de Log's do serviço do Apache2
# 04. systemctl status mysql = status do serviço do Oracle MySQL
# 05. tail -f /var/log/mysql/* = vários arquivos de Log's do serviço do MySQL
# 06. tail -f /var/log/tcpwrappers-allow-mysql.log = filtrando as conexões permitidas do MySQL
# 07. tail -f /var/log/tcpwrappers-deny.log = filtrando as conexões negadas do MySQL
# 08. journalctl -t phpmyadmin = todas as mensagens referente ao serviço do PhpMyAdmin
#
# Declarando as variáveis utilizadas nas configurações dos Serviços do LAMP-Server
#
# Variável do usuário padrão do MySQL (Root do Mysql, diferente do Root do GNU/Linux)
USERMYSQL="root"
#
# Variáveis da senha e confirmação da senha do usuário Root do Mysql 
SENHAMYSQL="pti@2018"
AGAIN=$SENHAMYSQL
#
# Variáveis de configuração e liberação da conexão remota para o usuário Root do MySQL
# opções do comando CREATE: create (criar), user (criação de usuário), user@'%' (usuário @ localhost), 
# identified by (identificado por - senha do usuário)
# opções do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas) to (para), user@'%' (usuário @ localhost), 
# opção do comando FLUSH: privileges (recarregar as permissões de privilegios)
CREATEUSER="CREATE USER '$USERMYSQL'@'%' IDENTIFIED BY '$SENHAMYSQL';"
GRANTALL="GRANT ALL ON *.* TO '$USERMYSQL'@'%';"
FLUSH="FLUSH PRIVILEGES;"
#
# Variável de configuração do usuário padrão de administração do PhpMyAdmin (Root do MySQL)
ADMINUSER=$USERMYSQL
#
# Variáveis da senha do usuário Root do Mysql e senha de administração o PhpMyAdmin
ADMIN_PASS=$SENHAMYSQL
APP_PASSWORD=$SENHAMYSQL
APP_PASS=$SENHAMYSQL
#
# Variável de configuração do serviço de hospedagem de site utilizado pelo PhpMyAdmin
WEBSERVER="apache2"
#
# Variável das dependências do laço de loop do LAMP Server
LAMPDEP="bind9 bind9utils"
#
# Variável de instalação do serviço de rede LAMP Server (^ (circunflexo): expressão regular)
LAMPINSTALL="lamp-server^ perl python apt-transport-https"
#
# Variável de instalação do serviço de rede PhpMyAdmin
PHPMYADMININSTALL="phpmyadmin php-bcmath php-mbstring php-pear php-dev php-json libmcrypt-dev pwgen"
#
# Variável da porta de conexão padrão do Apache2 Server
PORTPAPACHE="80"
#
# Variável da porta de conexão padrão do MySQL Server
PORTMYSQL="3306"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 08-openssl.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Certificados OpenSSL utilizados nesse script
# 01. /etc/ssl/index.txt = arquivo de configuração da base de dados do OpenSSL
# 02. /etc/ssl/index.txt.attr = arquivo de configuração dos atributos da base de dados do OpenSSL
# 03. /etc/ssl/serial = arquivo de configuração da geração serial dos certificados
# 04. /etc/ssl/pti-ca.conf = arquivo de configuração de Unidade Certificadora CA
# 05. /etc/ssl/pti-ssl.conf = arquivo de configuração do certificado do Apache2
# 06. /etc/apache2/sites-available/default-ssl.conf = arquivo de configuração do site HTTPS do Apache2
#
# Variáveis utilizadas na geração das chaves privadas/públicas dos certificados do OpenSSL
#
# Variável da senha utilizada na geração das chaves privadas/públicas da CA e dos certificados
PASSPHRASE="vaamonde"
#
# Variável do tipo de criptografia da chave privada com as opções de: -aes128, -aes192, -aes256, 
# -camellia128, -camellia192, -camellia256, -des, -des3 ou -idea, padrão utilizado: -aes256
CRIPTOKEY="aes256" 
#
# Variável do tamanho da chave privada utilizada em todas as configurações dos certificados,
# opções de: 1024, 2048, 3072 ou 4096, padrão utilizado: 2048
BITS="2048" 
#
# Variável da assinatura da chave de criptografia privada com as opções de: md5, -sha1, sha224, 
# sha256, sha384 ou sha512, padrão utilizado: sha256
CRIPTOCERT="sha256" 
#
# Variável do diretório de download da CA para instalação nos Desktops Windows e GNU/Linux
DOWNLOADCERT="/var/www/html/download/"
#
# Variável das dependências do laço de loop do OpenSSL
SSLDEP="openssl apache2 bind9"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 09-vsftpd.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede VSFTPd utilizados nesse script
# 01. /etc/vsftpd.conf = arquivo de configuração do servidor VSFTPd
# 02. /etc/vsftpd.allowed_users = arquivo de configuração da base de dados de usuários do VSFTPd
# 03. /etc/shells = arquivo de configuração do shells válidos
# 04. /etc/ssl/vsftpd-ssl.conf = arquivo de configuração da geração do certificado TLS/SSL
# 05. /bin/ftponly = arquivo de configuração da mensagem (banner) do VSFTPd
# 06. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
#
# Arquivos de monitoramento (log) do Serviço de Rede VSFTPd Server utilizados nesse script
# 01. systemctl status vsftpd = status do serviço do VSFTPd Server
# 02. tail -f /var/log/vsftpd.log = arquivo de Log's principal do serviço do VSFTPd Server
#
# Declarando as variáveis utilizadas nas configurações do Serviço do VSFTPd Server
#
# Variável de criação do Grupo dos Usuários de acesso ao VSFTPd Server
GROUPFTP="ftpusers"
#
# Variável de criação do Usuário de acesso ao VSFTPd Server
USERFTP="ftpuser"
#
# Variável da senha do Usuário de VSFTPd Server
PASSWORDFTP="ftpuser"
#
# Variável da senha utilizada na geração das chaves privadas/públicas de criptografia do OpenSSL 
PWDSSLFTP="vaamonde"
#
# Variável das dependências do laço de loop do VSFTPd Server
FTPDEP="bind9 bind9utils apache2 openssl"
#
# Variável de instalação do serviço de rede VSFTPd Server
FTPINSTALL="vsftpd"
#
# Variável da porta de conexão padrão do VSFTPd Server
PORTFTP="21"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 10-tomcat.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Servidor Apache Tomcat utilizados nesse script
# 01. /etc/tomcat9/tomcat-users.xml = arquivo de configuração dos usuários do Tomcat
# 02. /etc/tomcat9/server.xml = arquivo de configuração do servidor Tomcat
#
# Arquivos de monitoramento (log) do Serviço de Rede Tomcat Server utilizados nesse script
# 01. systemctl status tomcat9 = status do serviço do Tomcat Server
# 02. journalctl -t tomcat9 = todas as mensagens referente ao serviço do Tomcat9
# 03. tail -f /var/log/syslog | grep tomcat9 = filtrando as mensagens do serviço do Tomcat9
# 04. tail -f /var/log/tomcat9/* = vários arquivos de Log's do serviço do Tomcat9
#
# Declarando as variáveis utilizadas nas configurações do Serviço do Apache Tomcat9 Server
#
# Variável das dependências do laço de loop do Apache Tomcat9 Server
TOMCATDEP="bind9 bind9utils mysql-server mysql-common apache2 php vsftpd"
#
# Variável de instalação das dependências do Java do Apache Tomcat Server
TOMCATDEPINSTALL="openjdk-11-jdk openjdk-11-jre default-jdk"
#
# Variável de instalação do serviço de rede Apache Tomcat Server
TOMCATINSTALL="tomcat9 tomcat9-admin tomcat9-common tomcat9-docs tomcat9-examples tomcat9-user"
#
# Variáveis de localização do diretório de Configuração e do Webapp do Tomcat9
PATHTOMCAT9="/usr/share/tomcat9/"
PATHWEBAPPS="/var/lib/tomcat9/webapps"
#
# Variável da porta de conexão padrão do Apache Tomcat Server
PORTTOMCAT="8080"
#
# Variável de download da aplicação Agenda de Contatos em Java feita pelo Prof. José de Assis
# Link do Github do projeto: https://github.com/professorjosedeassis/javaEE
AGENDAJAVAEE="https://github.com/professorjosedeassis/javaEE/raw/main/agendaVaamonde.war"
#
# Variáveis de criação da Base de Dados da Agenda de Contatos no MySQL
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
# opções do domando CREATE: create (criação), table (tabela), colunas da tabela, primary key
# (coluna da chave primária)
#
# OBSERVAÇÃO: NO SCRIPT: 10-TOMCAT.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 267 até 270, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 217
NAME_DATABASE_JAVAEE="dbagenda"
USERNAME_JAVAEE=$NAME_DATABASE_JAVAEE
PASSWORD_JAVAEE=$NAME_DATABASE_JAVAEE
CREATE_DATABASE_JAVAEE="CREATE DATABASE dbagenda;"
CREATE_USER_DATABASE_JAVAEE="CREATE USER 'dbagenda' IDENTIFIED BY 'dbagenda';"
GRANT_DATABASE_JAVAEE="GRANT USAGE ON *.* TO 'dbagenda';"
GRANT_ALL_DATABASE_JAVAEE="GRANT ALL PRIVILEGES ON dbagenda.* TO 'dbagenda';"
FLUSH_JAVAEE="FLUSH PRIVILEGES;"
CREATE_TABLE_JAVAEE="CREATE TABLE contatos (
	idcon int NOT NULL AUTO_INCREMENT,
	nome varchar(50) NOT NULL,
	fone varchar(15) NOT NULL,
	email varchar(50) DEFAULT NULL,
	PRIMARY KEY (idcon)
);"
#
#=============================================================================================
#                      VARIÁVEIS UTILIZADAS NO SCRIPT: 11-wordpress.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do Site CMS Wordpress utilizados nesse script
# 01. /var/www/html/wp/wp-config.php = arquivo de configuração do site Wordpress
# 02. /var/www/html/wp/.htaccess = arquivo de segurança de páginas e diretórios do Wordpress
# 03. /etc/vsftpd.allowed_users = arquivo de configuração da base de dados de usuários do VSFTPd
# 04. /etc/apache2/sites-available/wordpress.conf = arquivo de configuração do Virtual Host
#
# Arquivos de monitoramento (log) do Site do Wordpress utilizado nesse script
# 01. tail -f /var/log/apache2/access-wordpress.log = log de acesso ao Wordpress
# 02. tail -f /var/log/apache2/error-wordpress.log = log de erro de acesso ao Wordpress
#
# Declarando as variáveis utilizadas nas configurações do Site do Wordpress
#
# Variável de localização da instalação do diretório do Wordpress
PATHWORDPRESS="/var/www/html/wp"
#
# Variável do download do Wordpress (Link atualizado em: 18/10/2021)
WORDPRESS="https://br.wordpress.org/latest-pt_BR.zip"
#
# Declarando as variáveis para criação da Base de Dados do Wordpress
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 11-WORDPRESS.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 267 até 270, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 217
CREATE_DATABASE_WORDPRESS="CREATE DATABASE wordpress;"
CREATE_USER_DATABASE_WORDPRESS="CREATE USER 'wordpress' IDENTIFIED BY 'wordpress';"
GRANT_DATABASE_WORDPRESS="GRANT USAGE ON *.* TO 'wordpress';"
GRANT_ALL_DATABASE_WORDPRES="GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress';"
FLUSH_WORDPRESS="FLUSH PRIVILEGES;"
#
# Variáveis de usuário e senha do FTP para acessar o diretório raiz da instalação do Wordpress
USERFTPWORDPRESS="wordpress"
PASSWORDFTPWORDPRESS="wordpress"
#
# Variável das dependências do laço de loop do Wordpress
WORDPRESSDEP="mysql-server mysql-common apache2 php vsftpd bind9"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 12-webmin.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Webmin e Usermin utilizados nesse script
# 01. /etc/apt/sources.list.d/webmin.list = arquivo de configuração do source list do Apt
#
# Arquivos de monitoramento (log) do Serviço do Webmin e do Usermin utilizados nesse script
# 01. journalctl -t webmin = todas as mensagens referente ao serviço do Webmin
# 02. tail -f /var/webmin/* = vários arquivos de Log's do serviço do Webmin
# 03. tail -f /var/usermin/* = vários arquivos de Log's do serviço do Usermin
#
# Declarando as variáveis utilizadas nas configurações do Webmin e do Usermin
# 
# Variável de download da Chave PGP do Webmin (Link atualizado no dia 30/11/2021)
WEBMINPGP="http://www.webmin.com/jcameron-key.asc"
#
# Variável da instalação das dependências do Webmin e do Usermin (\ quebra de linha no apt)
WEBMINDEP="perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl \
apt-show-versions python unzip apt-transport-https software-properties-common"
#
# Variável de instalação do serviço de rede Webmin e Usermin
WEBMINNSTALL="webmin usermin"
#
# Variáveis das portas de conexão padrão do Webmin e Usermin
PORTWEBMIN="10000"
PORTUSERMIN="20000"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 13-netdata.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Netdata utilizados nesse script
# 01. /usr/lib/netdata/conf.d/python.d/mysql.conf = arquivo de monitoramento do MySQL
# 02. /usr/lib/netdata/conf.d/python.d/isc_dhcpd.conf = arquivo de monitoramento do ISC DHCP
# 03. /usr/lib/netdata/conf.d/python.d/bind_rndc.conf = arquivo de monitoramento do Bind DNS
#
# Arquivos de monitoramento (log) do Serviço do Netdata utilizados nesse script
# 01. journalctl -t netdata = todas as mensagens referente ao serviço do Netdata
# 02. tail -f /var/log/netdata/* = vários arquivos de Log's do serviço do Netdata
# 03. tail -f /var/log/syslog | grep netdata = filtrando as mensagens do serviço do Netdata
#
# Declarando as variáveis utilizadas nas configurações do sistema de monitoramento Netdata
#
# Variável de download do Netdata (Link atualizado no dia 18/10/2021)
# opção do comando git clone --depth=1: Cria um clone superficial com um histórico truncado 
# para o número especificado de confirmações (somente o último commit geral do repositório)
NETDATA="https://github.com/firehol/netdata.git --depth=1"
#
# Variável das dependências do laço de loop do Netdata
NETDATADEP="mysql-server mysql-common apache2 php vsftpd bind9 isc-dhcp-server"
#
# Variável de instalação das dependências do Netdata (\ quebra de linha no apt)
NETDATAINSTALL="zlib1g-dev gcc make git autoconf autogen automake pkg-config uuid-dev python3 \
python3-mysqldb python3-pip python3-dev libmysqlclient-dev python-ipaddress libuv1-dev netcat \
libwebsockets15 libwebsockets-dev libjson-c-dev libbpfcc-dev liblz4-dev libjudy-dev libelf-dev \
libmnl-dev autoconf-archive curl cmake protobuf-compiler protobuf-c-compiler lm-sensors \
python3-psycopg2 python3-pymysql"
#
# Variável da porta de conexão padrão do Netdata
PORTNETDATA="19999"
#
# Declarando as variáveis para criação do usuário de monitoramento do Netdata no MySQL
# opções do comando CREATE: create (criação), user (usuário)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), replication cliente (),
# *.* (todos os bancos/tabelas), to (para), user (usuário)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 13-NETDATA.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 267 até 270, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 217
CREATE_USER_NETDATA="CREATE USER 'netdata'@'localhost';"
GRANT_USAGE_NETDATA="GRANT USAGE, REPLICATION CLIENT ON *.* TO 'netdata'@'localhost';"
FLUSH_NETDATA="FLUSH PRIVILEGES;"
#
#=============================================================================================
#                     VARIÁVEIS UTILIZADAS NO SCRIPT: 14-loganalyzer.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema LogAnalyzer utilizados nesse script
# 01. /etc/rsyslog.conf = arquivo de configuração do serviço de rede Rsyslog
# 02. /etc/rsyslog.d/mysql.conf = arquivo de configuração da base de dados do Rsyslog
# 03. /etc/apache2/sites-available/loganalyzer.conf = arquivo de configuração do Virtual host
#
# Arquivos de monitoramento (log) do Serviço do LogAnalyzer utilizados nesse script
# 01. journalctl -t rsyslogd = todas as mensagens referente ao serviço do Rsyslogd
# 02. tail -f /var/log/syslog = todos os Log's de serviços do Rsyslog
# 03. tail -f /var/log/apache2/access-loganalyzer.log = log de acesso ao LogAnalyzer
# 04. tail -f /var/log/apache2/error-loganalyzer.log = log de erro de acesso ao LogAnalyzer
#
# Declarando as variáveis utilizadas nas configurações do sistema de monitoramento LogAnalyzer
#
# Variável de localização da instalação do diretório do LogAnalyzer
PATHLOGANALYZER="/var/www/html/log"
#
# Variável de download do LogAnalyzer (atualizada no dia: 02/11/2021)
LOGANALYZER="http://download.adiscon.com/loganalyzer/loganalyzer-4.1.12.tar.gz"
#
# Variável de download do Plugin de Tradução PT-BR do LogAnalyzer (atualizada no dia: 02/11/2021)
LOGPTBR="https://loganalyzer.adiscon.com/plugins/files/translations/loganalyzer_lang_pt_BR_3.2.3.zip"
#
# Declarando as variáveis para criação da Base de Dados do Rsyslog
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 14-LOGANALYZER.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 267 até 270, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 217
CREATE_DATABASE_SYSLOG="CREATE DATABASE syslog;"
CREATE_USER_DATABASE_SYSLOG="CREATE USER 'syslog' IDENTIFIED BY 'syslog';"
GRANT_DATABASE_SYSLOG="GRANT USAGE ON *.* TO 'syslog';"
GRANT_ALL_DATABASE_SYSLOG="GRANT ALL PRIVILEGES ON syslog.* TO 'syslog';"
FLUSH_SYSLOG="FLUSH PRIVILEGES;"
DATABASE_NAME_SYSLOG="syslog"
INSTALL_DATABASE_SYSLOG="/usr/share/dbconfig-common/data/rsyslog-mysql/install/mysql"
#
# Declarando as variáveis para criação da Base de Dados do LogAnalyzer
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 14-LOGANALYZER.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 267 até 270, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 114
CREATE_DATABASE_LOGANALYZER="CREATE DATABASE loganalyzer;"
CREATE_USER_DATABASE_LOGANALYZER="CREATE USER 'loganalyzer' IDENTIFIED BY 'loganalyzer';"
GRANT_DATABASE_LOGANALYZER="GRANT USAGE ON *.* TO 'loganalyzer';"
GRANT_ALL_DATABASE_LOGANALYZER="GRANT ALL PRIVILEGES ON loganalyzer.* TO 'loganalyzer';"
FLUSH_LOGANALYZER="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do LogAnalyzer
LOGDEP="mysql-server mysql-common apache2 php bind9"
#
# Variável de instalação das dependências do LogAnalyzer
LOGINSTALL="rsyslog-mysql"
#
#=============================================================================================
#                         VARIÁVEIS UTILIZADAS NO SCRIPT: 15-glpi.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema GLPI Help Desk utilizados nesse script
# 01. /etc/apache2/conf-available/glpi.conf = arquivo de configuração do GLPI
# 02. /etc/apache2/sites-available/glpi.conf = arquivo de configuração do Virtual Host do GLPI
# 03. /etc/cron.d/glpi-cron = arquivo de configuração do agendamento do CRON do GLPI
#
# Arquivos de monitoramento (log) do Serviço do LogAnalyzer utilizados nesse script
# 01. tail -f /var/log/apache2/access-glpi.log = log de acesso ao GLPI Help Desk
# 02. tail -f /var/log/apache2/error-glpi.log = log de erro de acesso ao GLPI Help Desk
# 03. tail -f /var/log/syslog | grep -i glpi = filtrando as mensagens do serviço do GLPI Help Desk
#
# Declarando as variáveis utilizadas nas configurações do sistema de Help Desk GLPI
#
# Variável de localização da instalação do diretório do GLPI Help Desk
PATHGLPI="/var/www/html/glpi"
#
# Variável de download do GLPI (atualizada no dia: 25/11/2021)
GLPI="https://github.com/glpi-project/glpi/releases/download/9.5.6/glpi-9.5.6.tgz"
#
# Declarando as variáveis para criação da Base de Dados do GLPI
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 15-GLPI.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA DO
# ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 267 até 270, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 217
CREATE_DATABASE_GLPI="CREATE DATABASE glpi;"
CREATE_USER_DATABASE_GLPI="CREATE USER 'glpi' IDENTIFIED BY 'glpi';"
GRANT_DATABASE_GLPI="GRANT USAGE ON *.* TO 'glpi';"
GRANT_ALL_DATABASE_GLPI="GRANT ALL PRIVILEGES ON glpi.* TO 'glpi';"
FLUSH_GLPI="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do GLPI Help Desk
GLPIDEP="mysql-server mysql-common apache2 php bind9"
#
# Variável de instalação das dependências do GLPI Help Desk (\ quebra de linha no apt)
GLPIINSTALL="php-curl php-gd php-intl php-pear php-imagick php-imap php-memcache php-pspell \
php-mysql php-tidy php-xmlrpc php-mbstring php-ldap php-cas php-apcu php-json php-xml php-cli \
libapache2-mod-php xmlrpc-api-utils"
#
#=============================================================================================
#                    VARIÁVEIS UTILIZADAS NO SCRIPT: 16-fusioninventory.sh                   #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema FusionInventory utilizados nesse script
# 01. /etc/fusioninventory/agent.cfg = arquivo de configuração do agent do FusionInventory
#
# Arquivos de monitoramento (log) do Serviço do FusionInventory utilizados nesse script
# 01. journalctl -t fusioninventory-agent = todas as mensagens referente ao serviço do FusionInventory
# 02. tail -f /var/log/fusioninventory-agent/fusioninventory.log = arquivo de log do agent do FusionInventory
# 03. tail -f /var/log/syslog | grep -i fusioninventory = filtrando as mensagens do serviço do FusionInventory
#
# Declarando as variáveis utilizadas nas configurações do sistema de inventário FusionInventory
#
# Variável de download do FusionInventory Server e Agent (atualizada no dia: 30/11/2021)
# OBSERVAÇÃO: O FusionInventory depende do GLPI para funcionar corretamente, é recomendado sempre 
# manter o GLPI é o FusionInventory atualizados para as últimas versões compatíveis no site.
FUSIONSERVER="https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.5%2B3.0/fusioninventory-9.5+3.0.tar.bz2"
FUSIONAGENT="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_2.6-1_all.deb"
FUSIONCOLLECT="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent-task-collect_2.6-1_all.deb"
FUSIONNETWORK="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent-task-network_2.6-1_all.deb"
FUSIONDEPLOY="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent-task-deploy_2.6-1_all.deb"
AGENTWINDOWS32="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x86_2.6.exe"
AGENTWINDOWS64="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x64_2.6.exe"
AGENTMACOS="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/FusionInventory-Agent-2.6-2.dmg"
#
# Variável das dependências do laço de loop do FusionInventory Server
FUSIONDEP="mysql-server mysql-common apache2 php bind9"
#
# Variável de instalação das dependências do FusionInventory Agent (\ quebra de linha no apt)
AGENTINSTALL="dmidecode hwdata ucf hdparm perl libuniversal-require-perl libwww-perl libparse-edid-perl \
libproc-daemon-perl libfile-which-perl libhttp-daemon-perl libxml-treepp-perl libyaml-perl libnet-cups-perl \
libnet-ip-perl libdigest-sha-perl libsocket-getaddrinfo-perl libtext-template-perl libxml-xpath-perl \
libyaml-tiny-perl libio-socket-ssl-perl libnet-ssleay-perl libcrypt-ssleay-perl"
#
# Variável de instalação das dependências do FusionInventory Task Network
NETWORKINSTALL="libnet-snmp-perl libcrypt-des-perl libnet-nbname-perl"
#
# Variável de instalação das dependências do FusionInventory Task Deploy 
DEPLOYINSTALL="libfile-copy-recursive-perl libparallel-forkmanager-perl"
#
# Variável de instalação das dependências do FusionInventory Task WakeOnLan
WAKEINSTALL="libwrite-net-perl"
#
# Variável de instalação das dependências do FusionInventory SNMPv3
SNMPINSTALL="libdigest-hmac-perl"
#
# Variável do diretório de Download dos Agentes e arquivos de configuração do FusionInventory
DOWNLOADAGENT="/var/www/html/agentes"
#
# Variável da porta de conexão padrão do FusionInventory Server
PORTFUSION="62354"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 17-zoneminder.sh                     #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema ZoneMinder utilizados nesse script
# 01. /etc/mysql/mysql.conf.d/mysqld.cnf = arquivo de configuração do Servidor MySQL
# 02. /etc/php/7.4/apache2/php.ini = arquivo de configuração do PHP
#
# Arquivos de monitoramento (log) do Serviço do ZoneMinder utilizados nesse script
# 01. journalctl -t zoneminder = todas as mensagens referente ao serviço do ZoneMinder
# 02. tail -f /var/log/zm/* = vários arquivos de Log's do serviço do ZoneMinder
# 03. tail -f /var/log/syslog | grep -i zoneminder = filtrando as mensagens do serviço do ZoneMinder
#
# Declarando as variáveis utilizadas nas configurações do sistema de Câmeras ZoneMinder
#
# Variável do PPA (Personal Package Archive) do ZoneMinder (Link atualizado no dia 03/12/2021)
ZONEMINDER="ppa:iconnor/zoneminder-master"
#
# Declarando as variáveis para criação da Base de Dados do ZoneMinder
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 15-ZONEMINDER.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA DO
# ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 267 até 270, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 217
CREATE_DATABASE_ZONEMINDER="/usr/share/zoneminder/db/zm_create.sql"
CREATE_USER_DATABASE_ZONEMINDER="CREATE USER 'zmuser'@localhost IDENTIFIED BY 'zmpass';"
GRANT_DATABASE_ZONEMINDER="GRANT USAGE ON *.* TO 'zmuser'@'localhost';"
GRANT_ALL_DATABASE_ZONEMINDER="GRANT ALL PRIVILEGES ON zm.* TO 'zmuser'@'localhost' WITH GRANT OPTION;"
FLUSH_ZONEMINDER="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do ZoneMinder
ZONEMINDERDEP="apache2 mysql-server mysql-common software-properties-common php bind9"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 18-guacamole.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Guacamole utilizados nesse script
# 01. /etc/guacamole/guacamole.properties = 
# 02. /etc/guacamole/user-mapping.xml =
# 03. /etc/default/tomcat9 = 
#
# Declarando as variáveis utilizadas nas configurações do sistema de acesso remoto Guacamole
#
# Variável de download do Apache Guacamole (Links atualizados no dia 09/12/2021)
GUACAMOLESERVER="https://dlcdn.apache.org/guacamole/1.3.0/source/guacamole-server-1.3.0.tar.gz"
GUACAMOLECLIENT="https://dlcdn.apache.org/guacamole/1.3.0/binary/guacamole-1.3.0.war"
#
# Variável das dependências do laço de loop do Guacamole
GUACAMOLERDEP="tomcat9 tomcat9-admin tomcat9-user bind9"
#
# Variável de instalação das dependências do Guacamole (\ quebra de linha no apt)
GUACAMOLEINSTALL="libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev \
libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev \
libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev \
libvorbis-dev libwebp-dev gcc-10 g++-10 make libfreerdp2-2 freerdp2-dev freerdp2-x11"
#
# Variável da porta de conexão padrão do Guacamole Server
PORTGUACAMOLE="4822"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 19-grafana.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Grafana Server utilizados nesse script
# 01. /etc/default/grafana-server
#
# Declarando as variáveis utilizadas nas configurações do sistema de gráficos Grafana
#
# Variável da Chave GPG do Repositório do Grafana Server (Links atualizados no dia 09/12/2021)
GRAFANAGPGKEY="https://packages.grafana.com/gpg.key"
GRAFANAAPT="deb https://packages.grafana.com/oss/deb stable main"
#
# Variável das dependências do laço de loop do Grafana Server
GRAFANADEP="mysql-server mysql-common bind9 apt-transport-https software-properties-common"
#
# Variável da porta de conexão padrão do Grafana Server
PORTGRAFANA="3000"
#
#=============================================================================================
#                         VARIÁVEIS UTILIZADAS NO SCRIPT: 20-zabbix.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Zabbix Server utilizados nesse script
# 01. /etc/zabbix/zabbix_server.conf = 
# 02. /etc/zabbix/apache.conf =
# 03. /etc/zabbix/zabbix_agentd.conf = 
#
# Declarando as variáveis utilizadas nas configurações do sistema de monitoramento Zabbix Server
#
# Variável de download do Repositório do Zabbix Server (Link atualizado no dia 11/12/2021)
ZABBIXIREP="https://repo.zabbix.com/zabbix/5.5/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.5-1%2Bubuntu20.04_all.deb"
#
# Variável de instalação do Zabbix Server e suas Dependências.
ZABBIXINSTALL="install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent \
traceroute nmap snmp snmpd snmp-mibs-downloader"
#
# Declarando as variáveis para criação da Base de Dados do Zabbix Server
# opção do comando create: create (criação), database (base de dados), base (banco de dados), 
# character set (conjunto de caracteres), collate (comparar)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - 
# senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas),
# to (para), user (usuário), identified by (identificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), 
# *.* (todos os bancos/tabelas) to (para), user@'%' (usuário @ localhost), identified by (identificado 
# por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
CREATE_DATABASE_ZABBIX="CREATE DATABASE zabbix character set utf8 collate utf8_bin;"
CREATE_USER_DATABASE_ZABBIX="CREATE USER 'zabbix' IDENTIFIED BY 'zabbix';"
GRANT_DATABASE_ZABBIX="GRANT USAGE ON *.* TO 'zabbix';"
GRANT_ALL_DATABASE_ZABBIX="GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix';"
FLUSH_ZABBIX="FLUSH PRIVILEGES;"
CREATE_TABLE_ZABBIX="/usr/share/doc/zabbix-server-mysql/create.sql.gz"
#
# Variável das dependências do laço de loop do Zabbix Server
ZABBIXDEP="mysql-server mysql-common apache2 php bind9 apt-transport-https software-properties-common"
#
#=============================================================================================
#                         VARIÁVEIS UTILIZADAS NO SCRIPT: 21-docker.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Docker e do Portainer utilizados nesse script
# 01. 
#
# Declarando as variáveis utilizadas nas configurações do sistema de container Docker e Portainer
#
# Variável de download da chave GPG do Docker Community (Link atualizado no dia 15/12/2021)
DOCKERGPG="https://download.docker.com/linux/ubuntu/gpg"
DOCKERKEY="0EBFCD88"
DOCKERREP="deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
#
# Variável das dependências do laço de loop do Docker Community 
DOCKERDEP="bind9"
#
# Variável de instalação das Dependências do Docker Community e do Portainer.
DOCKERINSTALLDEP="apt-transport-https ca-certificates curl software-properties-common \
linux-image-generic linux-image-extra-virtual"
#
# Variável de instalação do Docker Community CE.
DOCKERINSTALL="docker-ce cgroup-lite"
#
