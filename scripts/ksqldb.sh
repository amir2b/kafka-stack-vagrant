#!/usr/bin/env bash

## Environments
INSTALATION_PATH="/vagrant"
KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS:-localhost:9092}
KSQL_KAFKA_USERNAME=${KSQL_KAFKA_USERNAME:-admin} # ToDo: It must change to ksql
KSQL_KAFKA_PASSWORD=${KSQL_KAFKA_PASSWORD:-password}
KSQLDB_VERSION=${KSQLDB_VERSION:-latest}

set -e

# Allow ksqlDB to discover the cluster:
/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --add --allow-principal User:ksql --operation DescribeConfigs --cluster

# Allow ksqlDB to read the input topics (including output-topic1):
/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --add --allow-principal User:ksql --operation Read --topic input-topic1 --topic input-topic2 --topic output-topic1

# Allow ksqlDB to write to the output topics:
/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --add --allow-principal User:ksql --operation Write --topic output-topic1 --topic output-topic2
# Or, if the output topics do not already exist, the 'create' operation is also required:
/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --add --allow-principal User:ksql --operation Create --operation Write --topic output-topic1 --topic output-topic2

# Allow ksqlDB to manage its own internal topics and consumer groups:
/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --add --allow-principal User:ksql --operation All --resource-pattern-type prefixed --topic _confluent-ksql-production_ --group _confluent-ksql-production_

# Allow ksqlDB to manage its record processing log topic, if configured:
/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --add --allow-principal User:ksql --operation All --topic production_ksql_processing_log

sudo mkdir -p /opt/ksqldb
sudo cp $INSTALATION_PATH/configs/ksqldb/docker-compose.yml /opt/ksqldb/

{
    echo "## KAFKA"
    echo "KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS}"
    echo "KAFKA_USERNAME=${KSQL_KAFKA_USERNAME}"
    echo "KAFKA_PASSWORD=${KSQL_KAFKA_PASSWORD}"
    echo
    echo "## KSQLDB"
    echo "KSQLDB_VERSION=${KSQLDB_VERSION}"
} | sudo tee /opt/ksqldb/.env

## Load docker image from cache
[ -f $INSTALATION_PATH/cache/ksqldb-server.tgz ] && sudo docker load --input $INSTALATION_PATH/cache/ksqldb-server.tgz || true
[ -f $INSTALATION_PATH/cache/ksqldb-cli.tgz ] && sudo docker load --input $INSTALATION_PATH/cache/ksqldb-cli.tgz || true

## Launch ksqlDB
sudo docker compose --project-directory /opt/ksqldb/ up --detach

## Export docker image to cache
[ ! -f $INSTALATION_PATH/cache/ksqldb-server.tgz ] && sudo docker save confluentinc/ksqldb-server | gzip > $INSTALATION_PATH/cache/ksqldb-server.tgz || true
[ ! -f $INSTALATION_PATH/cache/ksqldb-cli.tgz ] && sudo docker save confluentinc/ksqldb-cli | gzip > $INSTALATION_PATH/cache/ksqldb-cli.tgz || true
