#!/bin/bash

# =======================================
# INSTALADOR MYSQL + ZABBIX + GRAFANA
# VERSOES: 7.4 | 7.2 | 7.0 LTS | 6.0 LTS
# Desenvolvido por: BUG IT
# =======================================

# ===== CORES =====
VERMELHO="\e[31m"
VERDE="\e[32m"
VERDE_LIMAO="\e[92m"
AZUL_CLARO="\e[96m"
ROXO_CLARO="\e[95m"
LARANJA="\e[93m"
BRANCO="\e[97m"
NC="\033[0m"

# ===== VERIFICA ROOT =====
if [[ "$EUID" -ne 0 ]]; then
  echo -e "${VERMELHO}❌ Este script precisa ser executado como root!${NC}"
  exit 1
fi

# ===== DETECTA VERSAO DO SISTEMA =====
OS_NAME=$(grep '^NAME=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
OS_VERSION=$(grep '^VERSION_ID=' /etc/os-release | cut -d '=' -f2 | tr -d '"')

if [[ "$OS_NAME" != "Ubuntu" ]]; then
  echo -e "${VERMELHO}❌ Este script é compatível apenas com Ubuntu.${NC}"
  exit 1
fi

# ===== FUNÇÃO STATUS =====
status() {
  if [ $? -eq 0 ]; then
    echo -e "${VERDE}✅ Concluído${NC}\n"
  else
    echo -e "${VERMELHO}❌ Falhou${NC}\n"
    exit 1
  fi
}

# ===== MENU =====
clear
echo -e "${VERMELHO}"
cat << "EOF"
 █████╗ ██╗   ██╗████████╗ ██████╗     ███╗   ███╗███████╗ ██████╗ 
██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ████╗ ████║╚══███╔╝██╔════╝ 
███████║██║   ██║   ██║   ██║   ██║    ██╔████╔██║  ███╔╝ ██║  ███╗
██╔══██║██║   ██║   ██║   ██║   ██║    ██║╚██╔╝██║ ███╔╝  ██║   ██║
██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ██║ ╚═╝ ██║███████╗╚██████╔╝
╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚═╝     ╚═╝╚══════╝ ╚═════╝ 
EOF
echo -e "${NC}"

echo -e "${BRANCO}:: Instalação do ${LARANJA}Zabbix ${BRANCO}+${LARANJA} MySQL ${BRANCO}+${LARANJA} Grafana${NC}\n"
echo -e "${AZUL_CLARO}Selecione a versão do Zabbix:${NC}\n"
echo -e "${ROXO_CLARO}1)${BRANCO} Zabbix ${LARANJA}7.4"
echo -e "${ROXO_CLARO}2)${BRANCO} Zabbix ${LARANJA}7.2"
echo -e "${ROXO_CLARO}3)${BRANCO} Zabbix ${LARANJA}7.0 LTS"
echo -e "${ROXO_CLARO}4)${BRANCO} Zabbix ${LARANJA}6.0 LTS"
echo -e "${ROXO_CLARO}0)${VERMELHO} Sair${NC}\n"
read -p "$(echo -e "${BRANCO}Opção: ${ROXO_CLARO}")" OPTION_VER
echo

echo -e "${BRANCO}*****************************************\n"
echo -e "${AZUL_CLARO}Selecione o idioma padrão:${NC}\n"
echo -e "${ROXO_CLARO}1)${BRANCO} PORTUGUES"
echo -e "${ROXO_CLARO}2)${BRANCO} INGLES"
echo -e "${ROXO_CLARO}3)${BRANCO} ESPANHOL"
echo -e "${ROXO_CLARO}0)${VERMELHO} Sair${NC}\n"
read -p "$(echo -e "${BRANCO}Opção: ${ROXO_CLARO}")" OPTION_LANG

# ===== DEFINE VERSÕES =====
case "$OPTION_VER" in
  1) ZABBIX_VER="7.4" ; DIR="release" ;;
  2) ZABBIX_VER="7.2" ; DIR="release" ;;
  3) ZABBIX_VER="7.0" ;;
  4) ZABBIX_VER="6.0" ;;

  0) exit 0 ;;
  *) echo "Opção inválida!"; exit 1 ;;
esac

# ===== DEFINE LINGUAGEM =====
case "$OPTION_LANG" in
  1) ZABBIX_LANG="pt_BR" ;;
  2) ZABBIX_LANG="en_US" ;;
  3) ZABBIX_LANG="es_ES" ;;

  0) exit 0 ;;
  *) echo "Opção inválida!"; exit 1 ;;
esac

clear

# ===== DETECTA SISTEMA =====
echo -e "${BRANCO}💻 Detectando Sistema Operacional: ${ROXO_CLARO}${OS_NAME} ${OS_VERSION}\n"

# ===== REPOSITÓRIO =====
echo -e "${BRANCO}📥 Baixando Repositório do Zabbix ${LARANJA}${ZABBIX_VER}${BRANCO} para Ubuntu ${LARANJA}${OS_VERSION}${BRANCO}:"
URL="https://repo.zabbix.com/zabbix/${ZABBIX_VER}/${DIR}/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_${ZABBIX_VER}+ubuntu${OS_VERSION}_all.deb"

wget -q "$URL" -O "zabbix-release_${ZABBIX_VER}.deb"
status

echo -e "${BRANCO}📦 Instalando Repositório:"
dpkg -i "zabbix-release_${ZABBIX_VER}.deb" &>/dev/null
apt update -qq &>/dev/null
status

# ===== INSTALAÇÃO ZABBIX =====
echo -e "${BRANCO}📦 Instalando Zabbix Server:"
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent &>/dev/null
status

# ===== MYSQL =====
echo -e "${BRANCO}📦 Instalando MySQL Server:"
apt install -y mysql-server &>/dev/null
status

# Solicita senha root do MySQL
read -sp "$(echo -e "${BRANCO}🔑 Digite uma senha para o usuário ROOT do MySQL:")" MYSQL_ROOT_PASS
echo
echo -e "${VERDE}✅ Senha digitada: ${AZUL_CLARO}${MYSQL_ROOT_PASS}"
echo

# Solicita senha do usuário Zabbix
read -sp "$(echo -e "${BRANCO}🔑 Digite uma senha para o usuário DB Zabbix:")" DB_PASS
echo
echo -e "${VERDE}✅ Senha digitada: ${AZUL_CLARO}${DB_PASS}"
echo



# ===== CONFIGURA MYSQL =====
echo -e "${BRANCO}📦 Configurando Banco de Dados MySQL:"
mysql -u root <<EOF &>/dev/null
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASS}';
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
EOF
status

echo -e "${BRANCO}📦 Criando Usuário do Zabbix no MySQL:"
mysql -u root -p"${MYSQL_ROOT_PASS}" <<EOF &>/dev/null
CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
EOF
status

# ===== IMPORTAÇÃO DO BANCO ZABBIX =====
echo -e "${BRANCO}🔄 Importando base inicial do Zabbix:"

# Define caminho correto do server.sql.gz conforme a versão
if [[ "$ZABBIX_VER" == "7.4" || "$ZABBIX_VER" == "7.2" ]]; then
    SQL_FILE="/usr/share/zabbix/sql-scripts/mysql/server.sql.gz"
else
    SQL_FILE="/usr/share/zabbix-sql-scripts/mysql/server.sql.gz"
fi

# Verifica se o arquivo existe antes de importar
if [[ -f "$SQL_FILE" ]]; then
    zcat "$SQL_FILE" | mysql -u zabbix -p"${DB_PASS}" zabbix &>/dev/null
    status
else
    echo -e "${VERMELHO}❌ Arquivo SQL não encontrado: ${SQL_FILE}${NC}"
    exit 1
fi

mysql -u root -p"${MYSQL_ROOT_PASS}" -e "SET GLOBAL log_bin_trust_function_creators = 0; USE zabbix; UPDATE users SET lang = '${ZABBIX_LANG}' WHERE lang != '${ZABBIX_LANG}';" &>/dev/null

# ===== CONFIG ZABBIX SERVER =====
echo -e "${BRANCO}⚙️  Configurando zabbix_server.conf:"
sed -i "s/# DBPassword=/DBPassword=${DB_PASS}/" /etc/zabbix/zabbix_server.conf &>/dev/null
status

# ===== LOCALE =====
echo -e "${BRANCO}⏳ Configurando idioma ${LARANJA}${ZABBIX_LANG}${BRANCO}:"
locale-gen "${ZABBIX_LANG}.UTF-8" &>/dev/null
status

# ===== FRONTEND CONFIG =====
echo -e "${BRANCO}⏳ Configurando frontend do Zabbix:"
cat <<EOF > /etc/zabbix/web/zabbix.conf.php
<?php
\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = 'localhost';
\$DB['PORT']     = '0';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'zabbix';
\$DB['PASSWORD'] = '${DB_PASS}';

\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = 'Zabbix Server';

\$ZBX_LOCALE = '${ZABBIX_LANG}';
\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOF
status

# ===== GRAFANA =====
echo -e "${BRANCO}📦 Instalando Grafana:"
apt install -y apt-transport-https software-properties-common wget &>/dev/null
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg &>/dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list
apt update -qq &>/dev/null
apt install -y grafana &>/dev/null
status

# ===== SERVIÇOS =====
echo -e "${BRANCO}🔁 Habilitando e Iniciando os Serviços:"
systemctl enable zabbix-server zabbix-agent apache2 grafana-server &>/dev/null
systemctl restart zabbix-server zabbix-agent apache2 grafana-server &>/dev/null
status

# ===== FINAL =====
IP=$(hostname -I | awk '{print $1}')
echo
echo -e "${VERDE}🎉 Instalação Finalizada com Sucesso!"
echo
echo -e "${ROXO_CLARO}🔗${LARANJA} Zabbix: ${BRANCO}http://${AZUL_CLARO}${IP}${BRANCO}/zabbix (${LARANJA}login: ${AZUL_CLARO}Admin ${BRANCO}/${AZUL_CLARO} zabbix${BRANCO})"
echo -e "${ROXO_CLARO}🔗${LARANJA} Grafana: ${BRANCO}http://${AZUL_CLARO}${IP}${BRANCO}:3000 (${LARANJA}login: ${AZUL_CLARO}admin ${BRANCO}/${AZUL_CLARO} admin${BRANCO})"
echo -e "${ROXO_CLARO}🔗${LARANJA} MySQL: ${BRANCO}mysql -u ${AZUL_CLARO}root${BRANCO} -p (${LARANJA}login: ${AZUL_CLARO}root ${BRANCO}/${AZUL_CLARO} ${MYSQL_ROOT_PASS}${BRANCO})"
echo
echo -e "${BRANCO}Script desenvolvido por: ${VERDE_LIMAO}BUG IT${NC}"
echo -e
