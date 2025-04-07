data "azuread_client_config" "current" {}

resource "azuread_application" "my_app" {
  display_name = "MySampleApp"

  # Assign owners (the SP running Terraform, for example)
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "my_sp" {
  client_id = azuread_application.my_app.application_id

  owners = var.owner_ids
}