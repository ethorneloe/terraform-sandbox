variable "owner_ids" {
  type        = list(string)
  description = "List of additional owner UPNs to be added as owners."
  default     = []  // You can override this with TF_VAR_owner_ids.
}