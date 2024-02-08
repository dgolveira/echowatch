#!/bin/bash

# Definir variável do domínio VPN
#Deve conter o dns do servidor onde rodará seu servidor VPN...
VPN_DOMAIN="YOURDOMAIN.COM" # Substitua pelo seu domínio VPN

echo "Iniciando a configuração do OpenVPN para o domínio $VPN_DOMAIN..."

# Diretório para dados de configuração do OpenVPN
VPN_DATA="./openvpn-data"

# Criar diretório de dados do OpenVPN se não existir
if [ ! -d "$VPN_DATA" ]; then
    mkdir -p $VPN_DATA
    echo "Diretório de dados $VPN_DATA criado."
fi

# Gerar configuração do OpenVPN e certificados CA
echo "Gerando configuração do OpenVPN e certificados CA..."
docker run -v $PWD/openvpn-data:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://$VPN_DOMAIN
docker run -v $PWD/openvpn-data:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

# Solicitar o nome do cliente
echo -n "Digite o nome do cliente VPN e pressione [ENTER]: "
read CLIENTNAME

# Verificar se o CLIENTNAME foi fornecido
if [ -z "$CLIENTNAME" ]; then
    echo "Nome do cliente não fornecido. Saindo..."
    exit 1
fi

# Gerar certificado de cliente
echo "Gerando certificado para o cliente $CLIENTNAME..."
docker run -v $PWD/openvpn-data:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full $CLIENTNAME nopass

# Extrair arquivo de configuração .ovpn para o cliente
echo "Extraindo arquivo de configuração .ovpn para $CLIENTNAME..."
docker run -v $PWD/openvpn-data:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn

echo "Configuração do OpenVPN concluída."
echo "Arquivo de configuração .ovpn para o cliente $CLIENTNAME está pronto."
