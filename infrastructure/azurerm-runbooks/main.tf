data "azuread_client_config" "current" {}

resource "azuread_application" "my_app" {
  display_name = "MySampleApp2"

  # Assign owners (the SP running Terraform, for example)
  owners = [data.azuread_client_config.current.object_id, "55a1d6f3-896a-4707-9b82-e8013c4001d0"]
}

resource "azuread_service_principal" "my_sp" {
  client_id = azuread_application.my_app.client_id

  owners = [data.azuread_client_config.current.object_id, "55a1d6f3-896a-4707-9b82-e8013c4001d0"]
}