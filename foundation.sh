#!/bin/sh
# This script helps with installing OpenNMS Horizon with default settings;
#
# This script is for testing purposes!!!!
#
if test -f "/home/opennms/.installed"; then
    echo ".installed exists."
    exit 0
fi


sudo yum update -y && sudo yum install -y java-11-openjdk-devel postgresql postgresql-contrib

sudo dnf install langpacks-en glibc-all-langpacks -y
sudo localectl set-locale LANG=en_US.UTF-8
sudo localectl
sudo dnf makecache -y
sudo dnf update -y

sudo dnf -y install postgresql-server postgresql

sudo postgresql-setup --initdb --unit postgresql
sudo systemctl enable --now postgresql

sudo systemctl status postgresql

#sleep 20
export test_pgready=$(sudo -u postgres pg_isready > /dev/null 2>&1; echo $?)
while [ $test_pgready -ne 0 ]
do
 test_pgready=$(sudo -u postgres pg_isready > /dev/null 2>&1; echo $?)
 sleep 1
done


sudo -u postgres psql -c "CREATE USER opennms WITH PASSWORD 'opennms';"
sudo -u postgres createdb -O opennms opennms
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
sudo systemctl reload postgresql

#sleep 20
export test_pgready=$(sudo -u postgres pg_isready > /dev/null 2>&1; echo $?)
while [ $test_pgready -ne 0 ]
do
 test_pgready=$(sudo -u postgres pg_isready > /dev/null 2>&1; echo $?)
 sleep 1
done

curl -1sLf \
  'https://packages.opennms.com/public/common/setup.rpm.sh' \
  | sudo -E bash

curl -1sLf \
  'https://packages.opennms.com/public/foundation-2023/setup.rpm.sh' \
  | sudo -E bash

sleep 5
sudo DEBIAN_FRONTEND=noninteractive dnf -y install meridian tree
sudo dnf -y install epel-release
sudo dnf -y install R-core
sudo dnf config-manager --disable opennms-meridian-2023-testing-noarch

##sudo -u opennms vi /opt/opennms/etc/opennms-datasources.xml

Sudo def install patch -y

echo '--- /opt/opennms/etc/opennms-datasources.xml	2022-10-05 14:35:06.290040317 +0000
+++ /opt/opennms/etc/opennms-datasources.xml.backup	2022-10-05 19:01:57.315578426 +0000
@@ -23,5 +23,5 @@
                     class-name="org.postgresql.Driver"
                     url="jdbc:postgresql://localhost:5432/template1"
                     user-name="postgres"
-                    password="" />
+                    password="postgres" />
 </datasource-configuration>
' > /tmp/postgressettings.patch

sudo patch /opt/opennms/etc/opennms-datasources.xml /tmp/postgressettings.patch


sudo sed -i 's/ident/md5/g' /var/lib/pgsql/data/pg_hba.conf

sudo systemctl restart postgresql

sudo /opt/opennms/bin/fix-permissions
sudo /opt/opennms/bin/runjava -s
sudo /opt/opennms/bin/install -dis
sudo systemctl daemon-reload
sudo systemctl restart opennms

sleep 10
/usr/share/opennms/bin/opennms status > /home/opennms/.installed 2>&1
sudo systemctl enable --now opennms
##sudo systemctl status opennms
exit 0
