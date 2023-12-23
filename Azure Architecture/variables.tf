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