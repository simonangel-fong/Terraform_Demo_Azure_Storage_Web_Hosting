## Platform Level: Init Application

[Back](../README.md)

- [Platform Level: Init Application](#platform-level-init-application)
  - [Create Resource Group](#create-resource-group)
  - [Enable OIDC with GitHub Actions](#enable-oidc-with-github-actions)
  - [Enable GitHub Access to Terraform Backend Storage](#enable-github-access-to-terraform-backend-storage)
- [Teardown](#teardown)

---

### Create Resource Group

```sh
# App resource group
APP_RG_NAME="demo-storage-web-host-dev"
# App identity
APP_NAME="demo-storage-web-host"
# location
LOCATION="canadacentral"

# create resource group
az group create -n "$APP_RG_NAME"           \
    -l "$LOCATION"                          \
    --tags project="$APP_NAME" tier=platform managed_by=platform
```

---

### Enable OIDC with GitHub Actions

```sh
# ########################################
# 1. Create a Microsoft Entra Application
# ########################################
# app name
APP_NAME="demo-storage-web-host"


# Create a Microsoft Entra Application
az ad app create --display-name "$APP_NAME"
# confirm
az ad app list --display-name "$APP_NAME" --query "[].appId" -o tsv
APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[].appId" -o tsv | tr -d '\r' | xargs) && echo $APP_ID
# az ad app delete --id "$APP_ID"

# Create a Service Principal in Microsoft Entra Application
az ad sp create --id "$APP_ID"
# confirm
SP_ID=$(az ad sp show --id "$APP_ID" --query id -o tsv | tr -d '\r' | xargs) && echo $SP_ID
# az ad sp delete --id "$SP_ID"

# ##################################################
# 2. Configure the Federated Identity Credential
# ##################################################
# GitHb Owner
GH_OWNER="simonangel-fong"
# repo name
GH_REPO="Terraform_Demo_Azure_Storage_Web_Hosting"


# Create Federated Identity Credential
az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "gh-deploy",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'"$GH_OWNER"'/'"$GH_REPO"':ref:refs/heads/master",
  "audiences": ["api://AzureADTokenExchange"]
}'
# confirm
az ad app federated-credential list --id "$APP_ID" --query "[].id" -o tsv
# az ad app federated-credential delete --id "$APP_ID" --federated-credential-id $(az ad app federated-credential list --id "$APP_ID" --query "[].id" -o tsv | tr -d '\r' | xargs)

# ######################################################################
# Assign Role-Based Access Control (RBAC) to the Storage Account
# ######################################################################
# subscription id
SUB_ID=$(az account show --query id -o tsv | tr -d '\r' | xargs) && echo $SUB_ID
# resource group name
RG_NAME=$(echo -n "demo-storage-web-host-dev" | tr -d '\r') && echo $RG_NAME
# storage account name
SA_NAME=$(echo -n "demostoragewebhost" | tr -d '\r') && echo $SA_NAME


# Assign Contributor role to application
az role assignment create \
  --assignee "$APP_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME/providers/Microsoft.Storage/storageAccounts/$SA_NAME"
```

---

### Enable GitHub Access to Terraform Backend Storage

```sh
# Subscription id
SUB_ID=$(az account show --query id -o tsv | tr -d '\r') && echo $SUB_ID

# App id
APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[].appId" -o tsv | tr -d '\r' | xargs) && echo $APP_ID

# Service Principal id
SP_OBJECT_ID=$(az ad sp show --id "$APP_ID" --query id -o tsv | tr -d '\r' | xargs) && echo $SP_OBJECT_ID

# resource group name
RG_NAME=$(echo -n "demo-storage-web-host-dev" | tr -d '\r') && echo $RG_NAME

# TF Resource Group
TF_RG_NAME=$(echo -n "rg-tfstate-ca" | tr -d '\r') && echo $TF_RG_NAME
# TF Storage Account
TF_SA_NAME=$(echo -n "tfstatesf7592" | tr -d '\r') && echo $TF_SA_NAME

# ######################################################################
# Assign Contributor role to GitHub Actions to access TF storage
# ######################################################################
# Storage Blob Data Contributor
az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$TF_RG_NAME/providers/Microsoft.Storage/storageAccounts/$TF_SA_NAME"

# ######################################################################
# Assign Contributor role to GitHub Actions to access Resource Group
# ######################################################################
# Contributor: read RG + create SA, blobs, etc.
az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME"

# Storage Blob Data Contributor: needed later when TF uploads files to $web
az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME"

```

## Teardown

```sh
# Application Resource Group
APP_RG_NAME="demo-storage-web-host-dev"
# Application ID
APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[].appId" -o tsv | tr -d '\r' | xargs) && echo $APP_ID

# App SP + RBAC + federated credentials
az ad app delete --id "$APP_ID"

# App RG (and everything inside it)
az group delete -n "$APP_RG_NAME" --yes --no-wait
```
