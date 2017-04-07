#!/bin/bash
# curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.3.0.deb
# sudo dpkg -i --force-confnew elasticsearch-5.3.0.deb
# sudo service elasticsearch stop

curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.3.0.tar.gz
tar zxvf elasticsearch-5.3.0.tar.gz

cp -pR elasticsearch-5.3.0 /tmp/9200 && sed -i -e 's/#http.port: 9200/http.port: 9200/g' /tmp/9200/config/elasticsearch.yml
cp -pR elasticsearch-5.3.0 /tmp/9201 && sed -i -e 's/#http.port: 9200/http.port: 9201/g' /tmp/9201/config/elasticsearch.yml
cp -pR elasticsearch-5.3.0 /tmp/9202 && sed -i -e 's/#http.port: 9200/http.port: 9202/g' /tmp/9202/config/elasticsearch.yml
# cp -pR elasticsearch-5.3.0 /tmp/9203 && sed -i -e 's/#http.port: 9200/http.port: 9203/g' /tmp/9203/config/elasticsearch.yml
# cp -pR elasticsearch-5.3.0 /tmp/9204 && sed -i -e 's/#http.port: 9200/http.port: 9204/g' /tmp/9204/config/elasticsearch.yml

yes | /tmp/9200/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-kuromoji-neologd:5.2.1
yes | /tmp/9201/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-kuromoji-neologd:5.2.1
yes | /tmp/9202/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-kuromoji-neologd:5.2.1
# yes | /tmp/9203/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-kuromoji-neologd:5.2.1
# yes | /tmp/9204/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-kuromoji-neologd:5.2.1

((sh /tmp/9200/bin/elasticsearch) &) &> /dev/null
((sh /tmp/9201/bin/elasticsearch) &) &> /dev/null
((sh /tmp/9202/bin/elasticsearch) &) &> /dev/null
# sh /tmp/9203/bin/elasticsearch &
# sh /tmp/9204/bin/elasticsearch &
