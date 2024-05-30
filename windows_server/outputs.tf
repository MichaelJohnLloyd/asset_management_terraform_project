output "resource_group_name" {
  value = azurerm_resource_group.snipe_it_rg.name
}

output "public_ip_address" {
  value = azurerm_windows_virtual_machine.main.public_ip_addresses
}

output "admin_password" {
  sensitive = true
  value     = azurerm_windows_virtual_machine.main.admin_password
}

resource "local_file" "publice_ip_address" {
  content = azurerm_windows_virtual_machine.main.public_ip_address
  filename = "ip.txt"
}

resource "local_file" admin_password {
  content = azurerm_windows_virtual_machine.main.admin_password
  filename = "password.key"
}