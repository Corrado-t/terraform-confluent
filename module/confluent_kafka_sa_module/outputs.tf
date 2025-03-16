output "kafka_service_account" {
  description = "Map of created Confluent Kafka servive accounts"
  value       = confluent_service_account.main
}
