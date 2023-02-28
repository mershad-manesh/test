#!/bin/sh
# This script helps with installing OpenNMS Minion with default settings;
#
# This script is for testing purposes!!!!
#
if test -f "/home/opennms/.installed"; then
    echo ".installed exists."
    exit 0 
fi

curl -fsSL https://debian.opennms.org/OPENNMS-GPG-KEY | sudo gpg --dearmor -o /usr/share/keyrings/opennms.gpg
echo "deb [signed-by=/usr/share/keyrings/opennms.gpg] https://debian.opennms.org stable main" | sudo tee /etc/apt/sources.list.d/opennms.list
sudo apt update
sleep 5
sudo DEBIAN_FRONTEND=noninteractive sudo apt -y install opennms-minion

#echo '--- /usr/share/minion/etc/org.opennms.minion.controller.cfg	2022-10-05 14:35:06.290040317 +0000
#+++ /usr/share/minion/etc/org.opennms.minion.controller.cfg.backup	2022-10-05 19:01:57.315578426 +0000
#@@ -23,5 +23,5 @@
#                     class-name="org.postgresql.Driver" 
#                     url="jdbc:postgresql://localhost:5432/template1"
#                     user-name="postgres"
#-                    password="" />
#+                    password="postgres" />
# </datasource-configuration>
#' > /tmp/postgressettings.patch
#sudo patch /usr/share/opennms/etc/opennms-datasources.xml /tmp/postgressettings.patch
sudo systemctl enable --now minion
exit 0
