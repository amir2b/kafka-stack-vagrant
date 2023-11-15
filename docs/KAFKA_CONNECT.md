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