# Plan: Host a Static Website on Azure Storage

## Goal

Deploy a static website (custom HTML) to Azure Blob Storage's static website feature using Terraform, with state stored remotely. Optionally front it with a CDN + Cloudflare DNS for HTTPS on a custom domain.

## Repository Layout

```
web/                     # static site content
  index.html             # entry page
  404.html               # error page
infra/                   # terraform code
  01_variables.tf        # input parameters (env, location, project)
  02_providers.tf        # terraform + provider versions, remote backend
  03_locals.tf           # naming conventions, tags, computed values
  04_outputs.tf          # storage account name, primary web endpoint
  05_az_rg.tf            # resource group
  06_az_storage.tf       # storage account + static website + blob uploads
```

## Implementation Phases

### Phase 1 — Web Content

- Create `index.html` and `404.html` with minimal styled markup.
- Keep assets self-contained (no build step) so Phase 3 uploads stay trivial.

**Verify**

- Open files locally in a browser; confirm layout and 404 page render correctly.

---

### Phase 2 — Terraform Init

- Scaffold `infra/` files (`01`–`04`): variables, provider pins (`azurerm ~> 4.0`, `terraform >= 1.9`), `backend "azurerm"` for remote state, locals (`name_prefix`, tags), and outputs.
- Bootstrap the remote state container (one-time, manual or separate workspace) before `init`.

**Verify**

- `terraform init` — backend connects.
- `terraform fmt -check` — formatting clean.
- `terraform validate` — config valid.
- `terraform plan` — empty plan (no resources yet).

---

### Phase 3 — Azure Resources + Content Upload

- `05_az_rg.tf`: `azurerm_resource_group` named from `local.name_prefix`, tagged.
- `06_az_storage.tf`:
  - `azurerm_storage_account` — `StorageV2`, `Standard_LRS`, `min_tls_version = "TLS1_2"`, `https_traffic_only_enabled = true`.
  - `azurerm_storage_account_static_website` — `index_document = "index.html"`, `error_404_document = "404.html"`.
  - `azurerm_storage_blob` with `for_each = fileset("${path.module}/../web", "**")` into the `$web` container; map `content_type` by extension.
- `terraform apply`.

**Verify**

- `az storage account show -n <name>` — `staticWebsite.enabled = true`.
- `az storage blob list -c '$web' --account-name <name>` — files present.
- Browser: open `primary_web_endpoint` output → site loads, 404 page works.

---

### Phase 4 — CDN + Cloudflare (Optional)

- Add Azure CDN or Front Door in front of the storage endpoint for HTTPS + caching.
- Manage Cloudflare DNS via the `cloudflare` provider: `CNAME` record → CDN/Front Door hostname.
- Configure custom domain + managed cert on the CDN/Front Door resource.

**Verify**

- `curl -I https://<domain>` — `200 OK`, valid TLS cert chain.
- Browser: `https://<domain>` loads with padlock; cache headers present on static assets.

---

### Phase 5 - GitHub Actions pipeline (Optional)

- Setup ocid in az
- deploy pipeline: trigger by masster push
- destroy pipeline: manual
