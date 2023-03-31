#!/bin/sh
# This script helps with installing OpenNMS Horizon with default settings;
#
# This script is for testing purposes!!!!
#
if test -f "/home/opennms/.installed"; then
    echo ".installed exists."
    exit 0 
fi


sudo apt-get update && sudo apt-get install -y openjdk-11-jre-headless postgresql postgresql-contrib
sudo systemctl status postgresql

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

cat > /tmp/postgressettings.patch<< EOF
--- /etc/postgresql/10/main/postgresql.conf	2023-03-31 13:35:55.977934006 +0000
+++ postgresql.conf	2023-03-31 14:02:26.918918580 +0000
@@ -56,7 +56,7 @@
 
 # - Connection Settings -
 
-#listen_addresses = 'localhost'		# what IP address(es) to listen on;
+listen_addresses = '*'		# what IP address(es) to listen on;
 					# comma-separated list of addresses;
 					# defaults to 'localhost'; use '*' for all
 					# (change requires restart)
EOF

cat > /tmp/pg_hba.patch<< EOF
--- /etc/postgresql/10/main/pg_hba.conf	2023-03-31 13:35:55.957933974 +0000
+++ ./pg_hba.conf	2023-03-31 14:17:51.277888712 +0000
@@ -85,6 +85,7 @@
 local   all             postgres                                peer
 
 # TYPE  DATABASE        USER            ADDRESS                 METHOD
+host    all             all             172.21.0.0/24            md5
 
 # "local" is for Unix domain socket connections only
 local   all             all                                     peer
EOF


sudo patch /etc/postgresql/10/main/postgresql.conf /tmp/postgressettings.patch
sudo patch /etc/postgresql/10/main/pg_hba.conf /tmp/pg_hba.patch

sudo systemctl restart postgresql

#sleep 20
export test_pgready=$(sudo -u postgres pg_isready > /dev/null 2>&1; echo $?)
while [ $test_pgready -ne 0 ]
do 
 test_pgready=$(sudo -u postgres pg_isready > /dev/null 2>&1; echo $?)
 sleep 1
done

#sudo systemctl enable --now postgres

exit 0
