provider "azurerm" {
    version = "2.5.0"
    features {}
}

terraform {
    backend "azurerm" {
        resource_group_name  = "tf_rg_blobstorage"
        storage_account_name = "tfstorageashfakcode"
        container_name       = "tfstatejs"
        key                  = "terraform.tfstatejs"
    }
}

variable "imagebuild" {
  type        = string
  description = "Latest Image Build"
}


data "azurerm_resource_group" "tf_test" {
  name = "tfmainrg-js"
}

module "web_app_container" {
  source = "innovationnorway/web-app-container/azurerm"

  name = "ashfakcodejs"

  resource_group_name = data.azurerm_resource_group.tf_test.name

  container_type = "compose"

  container_config = <<EOF
version: '3.3'
services:
  my-app:
    image: ashfakcode/my-app-tf:${var.imagebuild}
    ports:
      - 8000:3000
  mongodb:
    image: mongo
    ports:
      - 27017:27017
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=password
    volumes:
      - mongo-data:/data/db
  mongo-express:
    image: mongo-express
    ports:
      - 9000:8081
    environment:
      - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
      - ME_CONFIG_MONGODB_ADMINPASSWORD=password
      - ME_CONFIG_MONGODB_SERVER=mongodb
volumes:
  mongo-data:
    driver: local
EOF
}
