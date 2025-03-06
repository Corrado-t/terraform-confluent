terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.19.0"
    }
  }
}

provider "confluent" {
  kafka_id            = var.kafka_id
  kafka_rest_endpoint = var.kafka_rest_endpoint
  kafka_api_key       = var.kafka_api_key
  kafka_api_secret    = var.kafka_api_secret
}

resource "confluent_kafka_acl" "main" {
  for_each      = var.acls
  resource_type = each.value.resource_type
  resource_name = each.value.resource_name
  pattern_type  = each.value.pattern_type
  principal     = each.value.principal
  host          = "*"
  operation     = each.value.operation
  permission    = each.value.permission
  # lifecycle {
  #   prevent_destroy = true
  # }
}
