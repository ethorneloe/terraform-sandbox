data "azuread_client_config" "current" {}

resource "azuread_application" "my_app" {
  display_name = "MySampleApp2"

  # Assign owners (the SP running Terraform, for example)
  owners = var.owner_ids
}

resource "azuread_service_principal" "my_sp" {
  client_id = azuread_application.my_app.client_id

  owners = var.owner_ids
}