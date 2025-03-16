terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.19.0"
    }
  }
}


data "confluent_kafka_cluster" "cluster" {
  environment {
    id = var.environment_id
  }
  id = var.kafka_id
}

resource "confluent_service_account" "main" {
  for_each     = var.users
  display_name = "${var.kafka_cluster_name}-${each.value.user_name}-${var.environment_name}"
  description  = each.value.description
}

resource "confluent_api_key" "main" {
  for_each     = var.users
  display_name = "${var.kafka_cluster_name}-${each.value.user_name}-${var.environment_name}-kafka-api-key"
  description  = "Kafka API Key that is owned by '${each.value.user_name}' service account"
  owner {
    id          = confluent_service_account.main[each.key].id
    api_version = confluent_service_account.main[each.key].api_version
    kind        = confluent_service_account.main[each.key].kind
  }
  managed_resource {
    id          = var.kafka_id
    api_version = data.confluent_kafka_cluster.cluster.api_version
    kind        = data.confluent_kafka_cluster.cluster.kind

    environment {
      id = var.environment_id
    }
  }
}