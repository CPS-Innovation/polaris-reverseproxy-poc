provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "UK South"
}

resource "azurerm_service_plan" "cnsdemo" {
  name                = "cnsdemo"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "cnsdemo" {
  name                = "cnsdemoapp"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example.location
  service_plan_id     = azurerm_service_plan.example.id
  site_config {
    application_stack {
      docker_image     = "registry.hub.docker.com/library/nginx"
      docker_image_tag = "1.23.3"
    }
  }
  auth_settings {
    enabled = true
    github {
      client_id                  = "SENSITIVE"
      client_secret_setting_name = "GITHUB_PROVIDER_AUTHENTICATION_SECRET"
    }
  }
  app_settings = {
    GITHUB_PROVIDER_AUTHENTICATION_SECRET = "SENSITIVE"
    UPSTREAM_HOST                         = "github.com"
    RESOLVER                              = "8.8.8.8"
    NGINX_ENVSUBST_OUTPUT_DIR             = "/etc/nginx"
    API_ENDPOINT                          = "api.github.com"
    FORCE_REFRESH_CONFIG                  = "${md5(file("default.conf"))}:${md5(file("nginx.js"))}"
  }
  storage_account {
    access_key   = azurerm_storage_account.example.primary_access_key
    account_name = azurerm_storage_account.example.name
    name         = "config"
    share_name   = azurerm_storage_container.example.name
    type         = "AzureBlob"
    mount_path   = "/etc/nginx/templates"
  }
}


resource "azurerm_storage_account" "example" {
  name                     = "cnsdemo"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "nginx_config" {
  name                   = "nginx.conf.template"
  content_md5            = md5(file("default.conf"))
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  source                 = "nginx.conf"
}
resource "azurerm_storage_blob" "nginx_js" {
  name                   = "nginx.js"
  content_md5            = md5(file("nginx.js"))
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  source                 = "nginx.js"
}