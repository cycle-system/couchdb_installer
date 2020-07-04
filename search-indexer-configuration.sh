#!/bin/bash

sudo mkdir /opt/clouseau

# Pull the version 2.17.0 of Clouseau plugin

wget https://github.com/cloudant-labs/clouseau/releases/download/2.17.0/clouseau-2.17.0-dist.zip
sudo unzip clouseau-2.17.0-dist.zip -d /opt/clouseau/lib/
sudo mv /opt/clouseau/lib/clouseau-2.17.0/* /opt/clouseau/lib/
sudo rm -rf /opt/clouseau/lib/clouseau-2.17.0

# Install Java 8

echo Y | sudo apt install openjdk-8-jdk

# Fill clouseau.ini file

touch clouseau.ini

echo '[clouseau]' >> clouseau.ini
echo '' >> clouseau.ini
echo '; the name of the Erlang node created by the service, leave this unchanged' >> clouseau.ini
echo 'name=clouseau@127.0.0.1' >> clouseau.ini
echo '' >> clouseau.ini
echo '; set this to the same distributed Erlang cookie used by the CouchDB nodes' >> clouseau.ini
echo 'cookie=monster' >> clouseau.ini
echo '' >> clouseau.ini
echo '; the path where you would like to store the search index files' >> clouseau.ini
echo 'dir=/path/to/index/storage' >> clouseau.ini
echo '' >> clouseau.ini
echo '; the number of search indexes that can be open simultaneously' >> clouseau.ini
echo 'max_indexes_open=500' >> clouseau.ini

sudo mv clouseau.ini /opt/clouseau/

# Create log4j file

touch log4j.properties

echo 'log4j.rootLogger=debug, CONSOLE' >> log4j.properties
echo 'log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender' >> log4j.properties
echo 'log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout' >> log4j.properties
echo 'log4j.appender.CONSOLE.layout.ConversionPattern=%d{ISO8601} %c [%p] %m%n' >> log4j.properties

sudo mv log4j.properties /opt/clouseau/

# Create launcher script

touch clouseau.sh

echo '#!/bin/bash' >> clouseau.sh
echo '' >> clouseau.sh
echo 'export CLASSPATH=/opt/clouseau/lib/*' >> clouseau.sh
echo '' >> clouseau.sh
echo '/usr/bin/java -server -Xmx2G -Dsun.net.inetaddr.ttl=30 -Dsun.net.inetaddr.negative.ttl=30 \' >> clouseau.sh
echo '-Dlog4j.configuration=file:/opt/clouseau/log4j.properties -XX:OnOutOfMemoryError="kill -9 %p" \' >> clouseau.sh
echo '-XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled com.cloudant.clouseau.Main /opt/clouseau/clouseau.ini' >> clouseau.sh

sudo chmod +x clouseau.sh

sudo mv clouseau.sh /opt/clouseau/

# Create a service script to launch on boot

touch clouseau.service

echo '[Unit]' >> clouseau.service
echo '' >> clouseau.service
echo 'Description=Clouseau' >> clouseau.service
echo 'After=network.target' >> clouseau.service
echo '' >> clouseau.service
echo '[Service]' >> clouseau.service
echo 'Type=simple' >> clouseau.service
echo 'User=root' >> clouseau.service
echo 'WorkingDirectory=/opt/clouseau' >> clouseau.service
echo 'ExecStart=/opt/clouseau/clouseau.sh' >> clouseau.service
echo 'Restart=on-abort' >> clouseau.service
echo '' >> clouseau.service
echo '[Install]' >> clouseau.service
echo 'WantedBy=multi-user.target' >> clouseau.service

sudo chmod 644 clouseau.service
sudo mv clouseau.service /lib/systemd/system/

# Launch Clouseau ser

sudo systemctl stop couchdb.service
sudo systemctl start couchdb.service
sudo systemctl enable couchdb.service

sudo systemctl start clouseau.service
sudo systemctl enable clouseau.service
