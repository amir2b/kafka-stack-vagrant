# kafka-stack-vagrant

All Apache Kafka components in Vagrant

## Setup

```shell
make init
make up

## Connenct to zookeeper server
# /opt/zookeeper/bin/zkCli.sh -server 127.0.0.1:2181

## List of topics
/opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list
## Create topic
/opt/kafka/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --topic test --partitions 1 --replication-factor 1
/opt/kafka/bin/kafka-topics.sh --describe --bootstrap-server localhost:9092 --topic test
## Produce
echo "Hi" | /opt/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
## Consume
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning

/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config adminclient-configs.conf  --add --allow-principal User:user --operation read --operation write --topic test


bin/kafka-acls --bootstrap-server localhost:9092 --command-config adminclient-configs.conf \
 --add --allow-principal User:<Sink Connector Principal> \
 --consumer --topic logs --group connect-hdfs-logs
```

```shell
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" 192.168.56.11:8083/connectors/ -d '{
  "name": "test",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.server.id": "112233",
    "database.hostname": "192.168.1.1",
    "database.port": "3306",
    "database.user": "cdc",
    "database.password": "password",
    "database.include.list": "inventory",
    "topic.prefix": "sfp",
    "snapshot.mode": "schema_only",
    "snapshot.locking.mode": "none",
    "schema.history.internal.store.only.captured.tables.ddl": true,
    "schema.history.internal.kafka.topic": "schema-changes.inventory",
    "schema.history.internal.kafka.bootstrap.servers": "localhost:9092",
    "schema.history.internal.producer.security.protocol": "SASL_PLAINTEXT",
    "schema.history.internal.producer.sasl.mechanism": "PLAIN",
    "schema.history.internal.producer.sasl.jaas.config": "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"cdc\" password=\"password\";",
    "schema.history.internal.consumer.security.protocol": "SASL_PLAINTEXT",
    "schema.history.internal.consumer.sasl.mechanism": "PLAIN",
    "schema.history.internal.consumer.sasl.jaas.config": "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"cdc\" password=\"password\";",
    "transforms": "unwrap",
    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
    "transforms.unwrap.drop.tombstones": "false",
    "internal.database.history.ddl.filter": "SAVEPOINT.*,# Dum.*,"
  }
}'

curl http://192.168.56.11:8083/connectors/test

curl -X PUT http://192.168.56.11:8083/connectors/test/pause
curl -X DELETE http://192.168.56.11:8083/connectors/test
```

## ToDo:

* https://kifarunix.com/setup-a-three-node-kafka-kraft-cluster/
* https://kifarunix.com/install-kadeck-apache-kafka-ui-tool-on-debian-ubuntu/
* https://kifarunix.com/configure-apache-kafka-ssl-tls-encryption/
* https://docs.confluent.io/platform/current/connect/references/restapi.html
* https://developer.ibm.com/tutorials/kafka-authn-authz/
* https://docs.confluent.io/platform/current/kafka/incremental-security-upgrade.html
* https://docs.confluent.io/platform/current/kafka/authentication_sasl/authentication_sasl_gssapi.html#jaas-config
* https://docs.confluent.io/platform/current/connect/security.html

## References

* https://docs.confluent.io/platform/current/connect/userguide.html
