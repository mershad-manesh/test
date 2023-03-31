#!/bin/sh
# This script helps with installing OpenNMS Horizon with default settings;
#
# This script is for testing purposes!!!!
#
if test -f "/home/opennms/.installed"; then
    echo ".installed exists."
    exit 0 
fi

sudo apt-key adv --fetch-keys https://debian.opennms.org/OPENNMS-GPG-KEY
sudo add-apt-repository -y -s 'deb https://debian.opennms.org stable main'
sleep 5
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install opennms r-recommended tree
##sudo -u opennms vi /usr/share/opennms/etc/opennms-datasources.xml
echo '--- opennms-datasources.xml.backup	2023-03-31 13:50:32.096391215 +0000
+++ opennms-datasources.xml	2023-03-31 13:55:27.197927783 +0000
@@ -14,14 +14,14 @@
   <jdbc-data-source name="opennms" 
                     database-name="opennms" 
                     class-name="org.postgresql.Driver" 
-                    url="jdbc:postgresql://localhost:5432/opennms"
+                    url="jdbc:postgresql://172.21.0.4:5432/opennms"
                     user-name="opennms"
                     password="opennms" />
 
   <jdbc-data-source name="opennms-admin" 
                     database-name="template1" 
                     class-name="org.postgresql.Driver" 
-                    url="jdbc:postgresql://localhost:5432/template1"
+                    url="jdbc:postgresql://172.21.0.4:5432/template1"
                     user-name="postgres"
-                    password="" />
+                    password="postgres" />
 </datasource-configuration>
' > /tmp/postgressettings.patch
sudo patch /usr/share/opennms/etc/opennms-datasources.xml /tmp/postgressettings.patch
sudo /usr/share/opennms/bin/fix-permissions
sudo /usr/share/opennms/bin/runjava -s
sudo /usr/share/opennms/bin/install -dis
sudo systemctl daemon-reload
sudo systemctl restart opennms
sudo ufw allow 8980/tcp
sleep 10
/usr/share/opennms/bin/opennms status > /home/opennms/.installed 2>&1
sudo systemctl enable --now opennms
##sudo systemctl status opennms
exit 0
