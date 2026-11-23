# Import the existing organization before managing its settings.
resource "buildkite_organization" "settings" {
  enforce_2fa = false

  # Keep existing IP policies until explicitly adding them to this configuration.
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      allowed_api_ip_addresses,
      allowed_api_ip_entries,
      allowed_browser_ip_entries,
    ]
  }
}
