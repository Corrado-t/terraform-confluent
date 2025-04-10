variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "env" {
  description = "Envrironment display name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS REGION"
  type        = string
  default     = "us-east-2"
}

variable "kafka_name" {
  description = "Kafka cluster display name"
  type        = string
  default     = "my-kafka-cluster"
}
