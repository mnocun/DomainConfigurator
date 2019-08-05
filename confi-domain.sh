#!/bin/bash

GREY='\033[0;37m'
NC='\033[0m'

echo -e "${GREY} ----------------------------------------------"
echo -e "${GREY} \e[1m KONFIGURATOR DOMEN"
echo -e "${GREY} ----------------------------------------------"
echo -e "${GREY} Autor: IKnowImNasty"
echo -e "${GREY} ----------------------------------------------"


ISITE_DIRECTORY_PATH='/var/www'
ISITE_EN=''

if [ -d /etc/httpd ];then
	IENGINE_IF_HTTPD=true
	ISITE_CONFIG_PATH='/etc/httpd'
	ISITE_EN='httpd'
else
	IENGINE_IF_HTTPD=false
	ISITE_CONFIG_PATH='/etc/apache2'
	ISITE_EN='apache2'
fi


IENGINE_DEFAULT_QUERY="[T/N] ( Zostaw puste jezeli nie )"

query_yes_no(){
	echo -en "${GREY}\e[1m$@ $IENGINE_DEFAULT_QUERY :" >&2
	read TEMP_FUNC_TN;
	case $TEMP_FUNC_TN in
  		't') TEMP_FUNC_TN=true;;
  		'T') TEMP_FUNC_TN=true;;
  		'n') TEMP_FUNC_TN=false;;
  		'N') TEMP_FUNC_TN=false;;
  		'') TEMP_FUNC_TN=false;;
  		*) echo -e "${GREY}\e[1mBAD INPUT - DOMYSLNA WARTOSC = NIE"; TEMP_FUNC_TN=false
	esac
}
while_read_empty(){
	read TEMP_FUNC_RE;
	while [[ -z $TEMP_FUNC_RE ]]; do
		echo -en "${GREY}\e[1m$@" >&2
		read TEMP_FUNC_RE;
	done
}


echo -en "${GREY}Nazwa rejestrowanej domeny: "
while_read_empty "Nazwa domeny nie moze byc pusta: "
ISITE_NAME=$TEMP_FUNC_RE

echo -e "${GREY} ----------------------------------------------"

query_yes_no "Utworzyc katalog o innej nazwie niz nazwa domeny ?"
ISITE_DIRECTORY_NAME=$TEMP_FUNC_TN

echo -e "${GREY} ----------------------------------------------"


if $ISITE_DIRECTORY_NAME; then
	echo -e "${GREY}Podaj nazwe katalogu: "
	while_read_empty "Nazwa katalogu nie moze byc pusta: "
	ISITE_DIRECTORY_NAME=$TEMP_FUNC_RE
	echo -e "${GREY} ----------------------------------------------"
else
	ISITE_DIRECTORY_NAME=$ISITE_NAME
fi

ENGINE_REWRITE_CONF=false

if [ -f $ISITE_CONFIG_PATH/sites-available/$ISITE_NAME.conf ];then
	query_yes_no "Plik $ISITE_NAME.conf istnieje ! Nadpisac zawartosc ?"
	if $TEMP_FUNC_TN;then
		echo > $ISITE_CONFIG_PATH/sites-available/$ISITE_NAME.conf
		ENGINE_REWRITE_CONF=true
	fi
	echo -e "${GREY} ----------------------------------------------"
else
	echo > $ISITE_CONFIG_PATH/sites-available/$ISITE_NAME.conf
	ENGINE_REWRITE_CONF=true
fi

if $ENGINE_REWRITE_CONF; then
	echo -e "<VirtualHost *:80>\nServerAdmin webmaster@$ISITE_DIRECTORY_NAME\nDocumentRoot /var/www/$ISITE_DIRECTORY_NAME/\nServerName $ISITE_NAME\nErrorLog /var/log/$ISITE_EN/$ISITE_NAME-error_log\nCustomLog /var/log/$ISITE_EN/$ISITE_NAME-access_log combined\n<Directory /var/www/$ISITE_NAME/>\nDirectoryIndex index.php\nOptions FollowSymLinks\nAllowOverride All\nRequire all granted\n</Directory>\n</VirtualHost>\n\n<VirtualHost *:443>\nServerAdmin webmaster@$ISITE_DIRECTORY_NAME\nServerName $ISITE_NAME\nDocumentRoot \"/var/www//$ISITE_DIRECTORY_NAME\"\nErrorLog /var/log/$ISITE_EN/$ISITE_NAME-SSL-error_log\nCustomLog /var/log/$ISITE_EN/$ISITE_NAME-SSL-access_log combined\n<Directory \"/var/www/$ISITE_DIRECTORY_NAME/\">\nDirectoryIndex index.php\nOptions FollowSymLinks\nAllowOverride All\nRequire all granted\n</Directory>\n</VirtualHost>\n" > $ISITE_CONFIG_PATH/sites-available/$ISITE_NAME.conf 
	echo -e "${GREY}\e[1mZmodyfikowano plik -> $ISITE_NAME.conf"
	echo -e "${GREY} ----------------------------------------------"
fi

if [ -d $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME ]; then
	query_yes_no "Katalog $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME już istnieje ! Usunac zawartosc ? "
	if $TEMP_FUNC_TN;then
		rm -fR $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME
		mkdir $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME
		echo -e "${GREY}\e[1mUsunieto zawartosc z katalogu $ISITE_DIRECTORY_NAME"
		echo -e "${GREY} ----------------------------------------------"
		ENGINE_CREATE_INDEX=true
	fi
else
	mkdir $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME
	echo -e "${GREY}\e[1mPomyslnie utworzono katalog $ISITE_DIRECTORY_NAME"
	echo -e "${GREY} ----------------------------------------------"
	ENGINE_CREATE_INDEX=true
fi

if $ENGINE_CREATE_INDEX; then
	query_yes_no "Utworzyc przykladowy plik index.php ?"
	if $TEMP_FUNC_TN; then
		echo -e "<!DOCTYPE HTML>\n<html lang=\"pl\">\n<head>\n<title>$ISITE_NAME</title>\n<style>*{margin:0;}body{width: 100vw;height: 100vh;}.conteiner{width: 100%;height: 100%;display:flex;justify-content:center;align-items:center;}</style></head>\n<body>\n<div class=\"conteiner\"><div class=\"content\">-- $ISITE_NAME --</div></div></body>\n</html>" > $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME/index.php
	fi
	echo -e "${GREY} ----------------------------------------------"
fi


if $IENGINE_IF_HTTPD; then
	ln -s $ISITE_CONFIG_PATH/sites-available/$ISITE_NAME.conf $ISITE_CONFIG_PATH/sites-enabled/$ISITE_NAME.conf
	systemctl restart httpd
else
	a2ensite $ISITE_NAME
	systemctl reload apache2
fi

echo -e "${GREY}\e[1mPomyslnie skonfigurowano domene na serwerze ;) "
echo -e "${GREY} ----------------------------------------------"

query_yes_no "Podpiac ssl ?"
ISITE_SSL=$TEMP_FUNC_TN

if $ISITE_SSL; then
	echo "SSL DISABLE"
fi
