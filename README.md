# Confluent Kafka Infrastructure Automation

This project automates the creation of **ACLs**, **Kafka topics**, and **service accounts** in Confluent Cloud using Terraform.

---

## Project Structure

Kafka topics, ACLs, and service accounts are defined in structured JSON files:

- `environment/dev/var/acls.json`
- `environment/dev/var/topics.json`
- `environment/dev/var/users.json`

---

## Service Account Naming Convention

Each user will be created using the following format:
<kafka_cluster_name><user_name>

Each user will have an associated Kafka API key, named:
<kafka_cluster_name><user_name>-kafka-api-key

## Environment and Cluster Setup

The `env.tf` file provides an example of how to provision a **Confluent environment** and **Kafka cluster**.

> **Note:** For production usage, it is recommended to separate responsibilities:
- Use **one repository** to create and manage the Confluent environment and cluster.
- Use **another repository** (structured like this one) to manage ACLs, topics, and service accounts for each cluster.

---

## Example Repository Layout
```
├── environment
│   ├── dev
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── var
│   │   │   ├── var.tfvars
│   │   │   ├── acls.json
│   │   │   ├── topics.json
│   │   │   └── users.json
│   │   ├── variables.tf
│   └── test
│   │   ├── .....
├── module
│   ├── confluent_kafka_acl_module
│   ├── confluent_kafka_sa_module
│   └── confluent_kafka_topics_module
└── README.md
```


