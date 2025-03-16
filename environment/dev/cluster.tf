

resource "confluent_environment" "staging" {
  display_name = "Staging"

  stream_governance {
    package = "ESSENTIALS"
  }
}

data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = confluent_environment.staging.id
  }

  depends_on = [
    confluent_kafka_cluster.basic
  ]
}

# Update the config to use a cloud provider and region of your choice.
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster
resource "confluent_kafka_cluster" "basic" {
  display_name = "inventory"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  basic {}
  environment {
    id = confluent_environment.staging.id
  }
}

// 'app-manager' service account is required in this configuration to create topic and grant ACLs
// to 'app-producer' and 'app-consumer' service accounts.
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
      id = confluent_environment.staging.id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-kafka-cluster-admin is created before
  # confluent_api_key.app-manager-kafka-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-kafka-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.app-manager-kafka-cluster-admin
  ]
}


