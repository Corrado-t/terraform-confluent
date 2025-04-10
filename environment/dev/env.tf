

resource "confluent_environment" "environment" {
  display_name = var.env

  stream_governance {
    package = "ESSENTIALS"
  }
}




