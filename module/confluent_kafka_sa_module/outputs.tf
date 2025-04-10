output "kafka_service_accounts" {
  description = "Map of created Confluent Kafka servive accounts"
  value       = confluent_service_account.main
}
