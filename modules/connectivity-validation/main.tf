provider "azurerm" {
  features {
  }
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "null_resource" "validation" {
  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type     = "ssh"
    user     = "azureuser"
    private_key = var.ssh_private_key
    host     = var.vm_public_ip_address
#    script_path = "${path.module}/script/connectivity_validation.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y oracle-instantclient-release-el8",
      "sudo dnf install -y oracle-instantclient-sqlplus",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/script/connectivity_validation.py"
    destination = "connectivity_validation.py"
  }

  provisioner "remote-exec" {
    inline = [
      "python3 connectivity_validation.py -p '${var.db_admin_password}' -s '${var.cdb_long_connection_string}' -c '${var.pdb_long_connection_string}'"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "cat connectivity_validation.log"
    ]
  }
}

