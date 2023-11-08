#!/usr/bin/env bash

## Environments
INSTALATION_PATH="/vagrant"

set -e

sudo mkdir -p /opt/kafka-ui/data
sudo cp $INSTALATION_PATH/configs/kafka-ui/dynamic_config.yaml /opt/kafka-ui/data/
sudo cp $INSTALATION_PATH/configs/kafka-ui/docker-compose.yml /opt/kafka-ui/
sudo chown 100:101 /opt/kafka-ui/data/ -R

{
    echo "## KAFKA_UI"
    echo "KAFKA_UI_VERSION=latest"
    echo "KAFKA_ui_USERNAME=user"
    echo "KAFKA_ui_PASSWORD=password"
} | sudo tee /opt/kafka-ui/.env

sudo docker compose --project-directory /opt/kafka-ui/ up --detach
