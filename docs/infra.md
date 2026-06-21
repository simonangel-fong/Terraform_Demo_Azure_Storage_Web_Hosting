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