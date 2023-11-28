#!/usr/bin/env bash

## Environments
INSTALATION_PATH="/vagrant"
KAFKA_UI_VERSION=${KAFKA_UI_VERSION:-latest}
KAFKA_ui_USERNAME=${KAFKA_ui_USERNAME:-user}
KAFKA_ui_PASSWORD=${KAFKA_ui_PASSWORD:-password}

set -e

sudo mkdir -p /opt/kafka-ui/data
sudo cp $INSTALATION_PATH/configs/kafka-ui/dynamic_config.yaml /opt/kafka-ui/data/
sudo cp $INSTALATION_PATH/configs/kafka-ui/docker-compose.yml /opt/kafka-ui/
sudo chown 100:101 /opt/kafka-ui/data/ -R

{
    echo "## KAFKA_UI"
    echo "KAFKA_UI_VERSION=${KAFKA_UI_VERSION}"
    echo "KAFKA_ui_USERNAME=${KAFKA_ui_USERNAME}"
    echo "KAFKA_ui_PASSWORD=${KAFKA_ui_PASSWORD}"
} | sudo tee /opt/kafka-ui/.env

/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --add --allow-principal User:user --consumer --topic '*' --group user

## Load docker image from cache
[ -f $INSTALATION_PATH/cache/kafka-ui.tgz ] && sudo docker load --input $INSTALATION_PATH/cache/kafka-ui.tgz || true

## Launch kafka-ui
sudo docker compose --project-directory /opt/kafka-ui/ up --detach

## Export docker image to cache
[ ! -f $INSTALATION_PATH/cache/kafka-ui.tgz ] && sudo docker save provectuslabs/kafka-ui | gzip > $INSTALATION_PATH/cache/kafka-ui.tgz || true
