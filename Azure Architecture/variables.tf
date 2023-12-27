variable "resource_group_name" {
  description = "resource_architecture"
}
variable "location" {
  description = "East US"
}
variable "app_service_plan_sku" {
  description = "This is the app service plan"
  default     = "F1"
}

variable "app_service_plan_name" {
  description = "This is the app service name"
}
variable "cosmosdb_name" {
  description = "The name of the cosmosDB account"
}

variable "app-authservice" {
  description = "The name of the app in app service"
}

variable "eventhub_namespace" {
  description = "The name of the Event Hub namespace"
}

variable "eventhub_name" {
  description = "The name of the Event Hub name"
}

variable "stacc_name" {
  description = "The name of the storage account"
}

variable "functionapp-name" {
  description = "The name of the function app"
}

variable "servicebus-namespace" {
  description = "The name of the service bus namespace"
}

variable "servicebus-queue1" {
  description = "The name of the first queue"
}

variable "aci-instance" {
  description = "The name of the ACI"
}