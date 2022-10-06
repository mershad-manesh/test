#!/bin/sh
# This script helps with installing OpenNMS Horizon with default settings;
#
# This script is for testing purposes!!!!
#
sudo apt update && sudo apt install -y openjdk-11-jre-headless postgresql postgresql-contrib
sudo systemctl status postgresql
sudo -u postgres psql -c "CREATE USER opennms WITH PASSWORD 'opennms';"
sudo -u postgres createdb -O opennms opennms
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
sudo systemctl reload postgresql
sudo apt-key adv --fetch-keys https://debian.opennms.org/OPENNMS-GPG-KEY
sudo add-apt-repository -y -s 'deb https://debian.opennms.org stable main'
sudo DEBIAN_FRONTEND=noninteractive apt -y install opennms r-recommended tree
##sudo -u opennms vi /usr/share/opennms/etc/opennms-datasources.xml
echo '--- /usr/share/opennms/etc/opennms-datasources.xml	2022-10-05 14:35:06.290040317 +0000
+++ /usr/share/opennms/etc/opennms-datasources.xml.backup	2022-10-05 19:01:57.315578426 +0000
@@ -23,5 +23,5 @@
                     class-name="org.postgresql.Driver" 
                     url="jdbc:postgresql://localhost:5432/template1"
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
sudo systemctl status opennms
