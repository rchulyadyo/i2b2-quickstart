#!/bin/bash
echo "running prescript with arg:$1"
#sed  -e "s/localhost/$1/" /conftemp/var/www/html/webclient/i2b2_config_data.js > /var/www/html/webclient/i2b2_config_data.js
#sed  -e "s/localhost/$1/" /conftemp/var/www/html/admin/i2b2_config_data.js > /var/www/html/admin/i2b2_config_data.js
sed  -e "s/i2b2-wildfly/$1/" /conftemp/etc/httpd/conf.d/i2b2_proxy.conf |sed -e s/9090/8080/ > /etc/httpd/conf.d/i2b2_proxy.conf
