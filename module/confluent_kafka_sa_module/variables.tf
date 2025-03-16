variable "environment_name" {
  description = "envirornmanet human readable name"
  type        = string
  sensitive   = true
}

variable "kafka_cluster_name" {
  description = "Kafka cluster human readable name"
  type        = string
}

variable "environment_id" {
  description = "The ID of the environment"
  type        = string
}

variable "kafka_id" {
  description = "The ID the the Kafka cluster of the form 'lkc-'"
  type        = string
}

variable "users" {
  description = "A map of Kafka user configurations"
  type = map(object({
    user_name   = string
    description = string
  }))
  default = {}
}



