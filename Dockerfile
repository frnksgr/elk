FROM ubuntu:14.04

# Run as 
# docker run -p 5000:5000 -p 5601:5601 -p 9200:9200 -d frnksgr/elk

MAINTAINER frnksgr@gmail.com

ENV ELASTICSEARCH_VERSION 2.4.0
ENV LOGSTASH_VERSION 2.4.0
ENV KIBANA_VERSION 4.6.1

ENV ELASTICSEARCH_TAR https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/${ELASTICSEARCH_VERSION}/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz
ENV LOGSTASH_TAR https://download.elastic.co/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz
ENV KIBANA_TAR https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz

# install packages
RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install wget openjdk-7-jre-headless

#  create elk user and directories
RUN useradd -r -s /bin/bash elk \
  && mkdir -p /opt/elk /var/run/elk /var/lib/elk /var/log/elk /etc/elk \
  && chown elk.elk /opt/elk /var/run/elk /var/lib/elk /var/log/elk /etc/elk 

# install elasticsearch
RUN cd /opt/elk \
  && echo fetching elasticsearch $ELASTICSEARCH_VERSION ... \
  && wget -q "$ELASTICSEARCH_TAR" -O elasticsearch.tgz \
  && echo installing elasticsearch $ELASTICSEARCH_VERSION ... \
  && tar -xzf elasticsearch.tgz \
  && mv elasticsearch-$ELASTICSEARCH_VERSION elasticsearch \
  && chown -R elk.elk elasticsearch \
  && rm elasticsearch.tgz 

# install logstash
RUN cd /opt/elk \
  && echo fetching logstash $LOGSTASH_VERSION ... \
  && wget -q "$LOGSTASH_TAR" -O logstash.tgz \
  && echo installing logstash $LOGSTASH_VERSION ... \
  && tar -xzf logstash.tgz \
  && mv logstash-$LOGSTASH_VERSION logstash \
  && chown -R elk.elk logstash \
  && rm logstash.tgz 

# install kibana
# NOTE: embedded node does not work on alpine
#       replaced by nodejs apk package
RUN cd /opt/elk \
  && echo fetching kibana $KIBANA_VERSION ... \
  && wget -q "$KIBANA_TAR" -O kibana.tgz \
  && echo installing kibana $KIBANA_VERSION ... \
  && tar -xzf kibana.tgz \
  && mv kibana-$KIBANA_VERSION-linux-x86_64 kibana \
  && chown -R elk.elk kibana \
  && rm kibana.tgz 

# configure
ADD logstash.conf /etc/elk/
ADD elasticsearch.yml /opt/elk/elasticsearch/config/
RUN chown elk.elk /etc/elk/* /opt/elk/elasticsearch/config/* \
  && ln -s /opt/elk/elasticsearch/config/elasticsearch.yml /etc/elk/elasticsearch.yml

# run
ADD elk /usr/local/bin/elk
ADD start .

VOLUME /var/lib/elk

# interfaec
EXPOSE 9200 5601 5000

CMD ./start

