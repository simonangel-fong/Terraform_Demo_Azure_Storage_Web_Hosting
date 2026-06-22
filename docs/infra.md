# Infra - Azure

[Back](../README.md)

---

- [Infra - Azure](#infra---azure)
  - [Provision Infra](#provision-infra)
  - [Confirm via Azure CLI](#confirm-via-azure-cli)

## Provision Infra

```sh
terraform -chdir=infra init -backend-config=backend.hcl
terraform -chdir=infra fmt -recursive
terraform -chdir=infra validate

terraform -chdir=infra plan
terraform -chdir=infra apply -auto-approve

terraform -chdir=infra destroy -auto-approve
```

---

## Confirm via Azure CLI

```sh
az group list --query "[?contains(name, 'demo-storage-web-host-dev')]" --output table
# Name                       Location
# -------------------------  -------------
# demo-storage-web-host-dev  canadacentral

az storage account show --name demostoragewebhost --resource-group 'demo-storage-web-host-dev' --query "name" --output table
# Result
# ------------------
# demostoragewebhost

```
