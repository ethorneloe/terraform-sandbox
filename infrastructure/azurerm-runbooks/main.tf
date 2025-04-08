###########################################################
# 0. Get info about the current Terraform service principal
###########################################################
data "azuread_client_config" "current" {}

###########################################################
# 1. Create the Azure AD Application
###########################################################
resource "azuread_application" "my_app" {
  display_name = "MySampleApp2"

  # Optionally set owners, so your Terraform principal (and another ID) can manage this app
  owners = [
    data.azuread_client_config.current.object_id,
    "55a1d6f3-896a-4707-9b82-e8013c4001d0"
  ]

  # (Optional) If you want to document these scopes on the application object itself,
  # you can specify them in required_resource_access. Not strictly required, but helpful
  # for clarity. You must know the specific GUIDs for each scope if you do it this way.
  #
  # required_resource_access {
  #   resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
  #   resource_access {
  #     id   = "<GUID-for-offline_access>"
  #     type = "Scope"
  #   }
  #   resource_access {
  #     id   = "<GUID-for-openid>"
  #     type = "Scope"
  #   }
  # }
  #
  # required_resource_access {
  #   resource_app_id = "e406a681-f3d4-42a8-90b6-c2b029497af1" # Azure Storage (verify in your tenant)
  #   resource_access {
  #     id   = "<GUID-for-user_impersonation>"
  #     type = "Scope"
  #   }
  # }
}

###########################################################
# 2. Create the Service Principal for the app
###########################################################
resource "azuread_service_principal" "my_sp" {
  # If you’re using AzureAD provider v2.x, use 'application_id' instead of 'client_id':
  client_id = azuread_application.my_app.application_id

  owners = [
    data.azuread_client_config.current.object_id,
    "55a1d6f3-896a-4707-9b82-e8013c4001d0"
  ]
}

###########################################################
# 3. Look up the resource service principals
#
# These data sources let us find the SPs for Microsoft Graph
# and Azure Storage so we can grant delegated scopes to them.
###########################################################
data "azuread_service_principal" "ms_graph" {
  client_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
}

data "azuread_service_principal" "azure_storage" {
  client_id = "e406a681-f3d4-42a8-90b6-c2b029497af1"  # Azure Storage
}

###########################################################
# 4. Grant delegated permissions (admin consent)
#    using azuread_service_principal_delegated_permission_grant
###########################################################

# Grant offline_access + openid to Microsoft Graph
resource "azuread_service_principal_delegated_permission_grant" "graph_grant" {
  service_principal_object_id   = azuread_service_principal.my_sp.object_id
  resource_service_principal_object_id = data.azuread_service_principal.ms_graph.object_id

  # Use the friendly scope names:
  claim_values = [
    "offline_access",
    "openid",
  ]
}

# Grant user_impersonation to Azure Storage
resource "azuread_service_principal_delegated_permission_grant" "storage_grant" {
  service_principal_object_id   = azuread_service_principal.my_sp.object_id
  resource_service_principal_object_id   = data.azuread_service_principal.azure_storage.object_id

  claim_values = [
    "user_impersonation"
  ]
}
