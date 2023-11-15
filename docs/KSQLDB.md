CREATE STREAM connect-configs-final AS
SELECT * FROM connect-configs
EMIT CHANGES;


docker compose exec ksqldb-cli /bin/ksql http://ksqldb-server:8088

docker compose exec ksqldb-cli /bin/ksql --define topic=my_topic --file /path/to/statements.sql -- http://ksqldb-server:8088