output "created_kafka_topics" {
  description = "Map of created Confluent Kafka topics"
  value       = module.confluent_kafka_topics.kafka_topics
}

output "created_kafka_service_accounts" {
  description = "Map of created Confluent Kafka service accounts"
  value       = module.confluent_kafka_service_accounts.kafka_service_accounts
}
output "created_kafka_acls" {
  description = "Map of created Confluent Kafka ACLs"
  value       = module.confluent_kafka_acls.kafka_acls
}