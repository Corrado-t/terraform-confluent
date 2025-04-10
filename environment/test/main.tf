terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.19.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

// Get environment ID
data "confluent_environment" "environment" {
  display_name = var.env
}
// Create Kafka cluster

resource "confluent_kafka_cluster" "basic" {
  display_name = var.kafka_name
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = var.region
  basic {}
  environment {
    id = data.confluent_environment.environment.id
  }
}

// 'app-manager' service account is required in this configuration to create topic and grant ACLs
resource "confluent_service_account" "app-manager" {
  display_name = "app-manager"
  description  = "Service account to manage 'inventory' Kafka cluster"
}

resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic.rbac_crn
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }
  depends_on = [
    confluent_role_binding.app-manager-kafka-cluster-admin
  ]
}

// Create service account 
module "confluent_kafka_service_accounts" {
  source = "../../module/confluent_kafka_sa_module"

  kafka_id           = confluent_kafka_cluster.basic.id
  environment_id     = data.confluent_environment.environment.id
  kafka_cluster_name = confluent_kafka_cluster.basic.display_name
  environment_name   = var.env
  users              = jsondecode(file("var/users.json"))
}

// Note that in order to consume from a topic, the principal of the consumer ('app-consumer' service account)
// needs to be authorized to perform 'READ' operation on both Topic and Group resources:
// confluent_kafka_acl.app-consumer-read-on-topic, confluent_kafka_acl.app-consumer-read-on-group.
// https://docs.confluent.io/platform/current/kafka/authorization.html#using-acls

// Create ACLs
module "confluent_kafka_acls" {
  source = "../../module/confluent_kafka_acl_module"

  kafka_id            = confluent_kafka_cluster.basic.id
  kafka_rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  kafka_api_key       = confluent_api_key.app-manager-kafka-api-key.id
  kafka_api_secret    = confluent_api_key.app-manager-kafka-api-key.secret
  acls                = jsondecode(file("var/acls.json"))
}

// Create topics
module "confluent_kafka_topics" {
  source = "../../module/confluent_kafka_topics_module"

  kafka_id            = confluent_kafka_cluster.basic.id
  kafka_rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  kafka_api_key       = confluent_api_key.app-manager-kafka-api-key.id
  kafka_api_secret    = confluent_api_key.app-manager-kafka-api-key.secret
  topics              = jsondecode(file("var/topics.json"))
}

