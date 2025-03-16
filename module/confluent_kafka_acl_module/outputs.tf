output "kafka_acls" {
  description = "Map of created Confluent Kafka acls"
  value       = confluent_kafka_acl.main
}
