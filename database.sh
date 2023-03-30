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

#sleep 20
export test_pgready=$(sudo -u postgres pg_isready > /dev/null 2>&1; echo $?)
while [ $test_pgready -ne 0 ]
do 
 test_pgready=$(sudo -u postgres pg_isready > /dev/null 2>&1; echo $?)
 sleep 1
done

exit 0
