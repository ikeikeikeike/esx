#!/bin/bash
curl -O https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.4.3/elasticsearch-2.4.3.deb
sudo dpkg -i --force-confnew elasticsearch-2.4.3.deb

curl -O https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.4.3/elasticsearch-2.4.3.tar.gz
tar zxvf elasticsearch-2.4.3.tar.gz

cp -pR elasticsearch-2.4.3 /tmp/9200 && sed -i -e 's/# http.port: 9200/http.port: 9200/g' /tmp/9200/config/elasticsearch.yml
cp -pR elasticsearch-2.4.3 /tmp/9201 && sed -i -e 's/# http.port: 9200/http.port: 9201/g' /tmp/9201/config/elasticsearch.yml
cp -pR elasticsearch-2.4.3 /tmp/9202 && sed -i -e 's/# http.port: 9200/http.port: 9202/g' /tmp/9202/config/elasticsearch.yml
cp -pR elasticsearch-2.4.3 /tmp/9203 && sed -i -e 's/# http.port: 9200/http.port: 9203/g' /tmp/9203/config/elasticsearch.yml
cp -pR elasticsearch-2.4.3 /tmp/9204 && sed -i -e 's/# http.port: 9200/http.port: 9204/g' /tmp/9204/config/elasticsearch.yml

sh /tmp/9200/bin/elasticsearch &
sh /tmp/9201/bin/elasticsearch &
sh /tmp/9202/bin/elasticsearch &
sh /tmp/9203/bin/elasticsearch &
sh /tmp/9204/bin/elasticsearch &
