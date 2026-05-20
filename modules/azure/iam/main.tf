# ── User Assigned Managed Identity ────────────────────────────────────────────

resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# ── Federated Credential (Workload Identity) ───────────────────────────────────

resource "azurerm_federated_identity_credential" "this" {
  count = var.k8s_service_account != "" ? 1 : 0

  name                = "${var.name}-federated"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account}"
}

# ── Role Assignments ───────────────────────────────────────────────────────────

resource "azurerm_role_assignment" "this" {
  for_each = { for idx, ra in var.role_assignments : idx => ra }

  scope                = each.value.scope
  role_definition_name = each.value.role_name
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}
