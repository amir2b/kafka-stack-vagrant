```shell
## List of topics
/opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --list

## Create topic
/opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --create --topic test --partitions 1 --replication-factor 1
/opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --describe --topic test

## Produce
echo "Hi" | /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --producer.config /opt/kafka/config/admin.conf --topic test

## Consume
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --consumer.config /opt/kafka/config/admin.conf --topic test --from-beginning

## ACL
/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --add --allow-principal User:user --operation read --operation write --topic test

/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --add --allow-principal User:cdc --consumer --topic test --group connect-test

/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --list
```
