#!/bin/bash

GREY='\033[0;37m'
NC='\033[0m'

echo -e "${GREY} ----------------------------------------------"
echo -e "${GREY} \e[1m DOMAIN CONFIGURATIOR"
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


IENGINE_DEFAULT_QUERY="[Y/N] ( Leave blank if not )"

query_yes_no(){
	echo -en "${GREY}\e[1m$@ $IENGINE_DEFAULT_QUERY :" >&2
	read TEMP_FUNC_TN;
	case $TEMP_FUNC_TN in
  		'y') TEMP_FUNC_TN=true;;
  		'Y') TEMP_FUNC_TN=true;;
  		'n') TEMP_FUNC_TN=false;;
  		'N') TEMP_FUNC_TN=false;;
  		'') TEMP_FUNC_TN=false;;
  		*) echo -e "${GREY}\e[1mBAD INPUT - DEFAULT VALUE = NO\e[0m"; TEMP_FUNC_TN=false
	esac
}
while_read_empty(){
	read TEMP_FUNC_RE;
	while [[ -z $TEMP_FUNC_RE ]]; do
		echo -en "${GREY}\e[1m$@" >&2
		read TEMP_FUNC_RE;
	done
}


echo -en "${GREY}Name of the registered domain: "
while_read_empty "The domain name cannot be empty: "
ISITE_NAME=$TEMP_FUNC_RE

echo -e "${GREY} ----------------------------------------------"

query_yes_no "Create a directory with a different name than the domain name?"
ISITE_DIRECTORY_NAME=$TEMP_FUNC_TN

echo -e "${GREY} ----------------------------------------------"


if $ISITE_DIRECTORY_NAME; then
	echo -e "${GREY}Enter a directory name: "
	while_read_empty "Directory name cannot be empty: "
	ISITE_DIRECTORY_NAME=$TEMP_FUNC_RE
	echo -e "${GREY} ----------------------------------------------"
else
	ISITE_DIRECTORY_NAME=$ISITE_NAME
fi

ENGINE_REWRITE_CONF=false

if [ -f $ISITE_CONFIG_PATH/sites-available/$ISITE_NAME.conf ];then
	query_yes_no "File $ISITE_NAME.conf already exist ! Overwrite the content?"
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
	echo -e "<VirtualHost *:80>\nServerAdmin webmaster@$ISITE_DIRECTORY_NAME\nDocumentRoot \"/var/www/$ISITE_DIRECTORY_NAME/\"\nServerName $ISITE_NAME\nErrorLog \"/var/log/$ISITE_EN/$ISITE_NAME-error_log\"\nCustomLog \"/var/log/$ISITE_EN/$ISITE_NAME-access_log\" combined\n<Directory \"/var/www/$ISITE_NAME/\">\nDirectoryIndex index.php\nOptions FollowSymLinks\nAllowOverride All\nRequire all granted\n</Directory>\n</VirtualHost>\n\n<VirtualHost *:443>\nServerAdmin webmaster@$ISITE_DIRECTORY_NAME\nServerName $ISITE_NAME\nDocumentRoot \"/var/www/$ISITE_DIRECTORY_NAME\"\nErrorLog \"/var/log/$ISITE_EN/$ISITE_NAME-SSL-error_log\"\nCustomLog \"/var/log/$ISITE_EN/$ISITE_NAME-SSL-access_log\" combined\n<Directory \"/var/www/$ISITE_DIRECTORY_NAME/\">\nDirectoryIndex index.php\nOptions FollowSymLinks\nAllowOverride All\nRequire all granted\n</Directory>\n</VirtualHost>\n" > $ISITE_CONFIG_PATH/sites-available/$ISITE_NAME.conf 
	echo -e "${GREY}\e[1mFile modified -> $ISITE_NAME.conf"
	echo -e "${GREY} ----------------------------------------------"
fi

if [ -d $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME ]; then
	query_yes_no "Catalog $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME already exist! Delete content? "
	if $TEMP_FUNC_TN;then
		rm -fR $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME
		mkdir $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME
		echo -e "${GREY}\e[1mContent removed from directory $ISITE_DIRECTORY_NAME"
		echo -e "${GREY} ----------------------------------------------"
		ENGINE_CREATE_INDEX=true
	fi
else
	mkdir $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME
	echo -e "${GREY}\e[1mDirectory created successfully $ISITE_DIRECTORY_NAME"
	echo -e "${GREY} ----------------------------------------------"
	ENGINE_CREATE_INDEX=true
fi

if $ENGINE_CREATE_INDEX; then
	query_yes_no "Create a sample index.php file?"
	if $TEMP_FUNC_TN; then
		echo -e "<!DOCTYPE HTML>\n<html lang=\"pl\">\n<head>\n<title>$ISITE_NAME</title>\n<link href=\"https://fonts.googleapis.com/css?family=Raleway&display=swap\" rel=\"stylesheet\">\n<style>body{margin:0}h1{width:100vw;height:100vh;line-height:100vh;color:#2c2c2c;text-transform:uppercase;background-color:#d5d5d5;letter-spacing:0.05em;text-shadow:4px 4px 0px #d5d5d5,7px 7px 0px rgba(0, 0, 0, 0.2);font-family:\"Raleway\",sans-serif;font-size:32px;margin:0;text-align:center;text-transform:uppercase;text-rendering:optimizeLegibility;}</style>\n</head>\n<body><h1>$ISITE_NAME</h1></body></html>" > $ISITE_DIRECTORY_PATH/$ISITE_DIRECTORY_NAME/index.php
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

echo -e "${GREY}\e[1mYou have successfully configured the domain on the server ;) "
echo -e "${GREY} ----------------------------------------------\e[0m"