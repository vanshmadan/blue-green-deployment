# Blue-Green Deployment Pipeline using Jenkins and Terraform (DigitalOcean)

## 🧭 Objective

This project implements a **blue-green deployment pipeline** using Jenkins and Terraform for DigitalOcean infrastructure.

It:
- Provisions two droplets (`blue` and `green`) and a floating IP.
- Detects which droplet is currently active.
- Shifts traffic to the new healthy droplet using the floating IP.
- Tears down the old droplet after successful validation.

---

## 🚀 Technologies

- **Terraform** (with DigitalOcean provider)
- **Jenkins** (Scripted Pipeline)
- **DigitalOcean API**
- **Bash** **/** **curl**
- **Groovy**

---

## 🔁 Jenkins Pipeline Stages

### 1. Terraform Init

```bash
terraform init -reconfigure
```

### 2. Apply Infra Only (No Floating IP Assignment)

```bash
terraform apply \
  -target=digitalocean_droplet.blue \
  -target=digitalocean_droplet.green \
  -target=digitalocean_floating_ip.app_ip \
  -auto-approve
```

### 3. Extract Outputs

Terraform outputs:
- `floating_ip`
- `blue_id`
- `green_id`

### 4. Detect Active Droplet

The script `scripts/fetch_active_droplet.sh`:
- Calls the DigitalOcean API to find which droplet owns the floating IP.
- Falls back to checking blue/green if IP is unassigned.
- Outputs `active_droplet_id` in JSON.

### 5. Health Check New Droplet

Uses the IP of the new (inactive) droplet:

```bash
curl -sf http://<new_ip>:8080/health
```

- Retries 10x with 30s delay (max 10 minutes timeout)

### 6. Reassign Floating IP to New Droplet

```bash
terraform apply -auto-approve -var="active_droplet_id=<new_droplet_id>"
```

### 7. Destroy Old Droplet

```bash
terraform destroy -target=digitalocean_droplet.<old_droplet> -auto-approve
```

### 8. Final Health Check

```bash
curl -sf http://<floating_ip>:8080/health
```

---

## 📂 Required Files

- `main.tf` — Terraform infra definition
- `vars.tf` — Terraform variables (include `active_droplet_id` with `default = null`)
- `scripts/fetch_active_droplet.sh` — Bash script to detect active droplet

---

## 🔌 Jenkins Plugin Dependencies

- [x] **Pipeline Utility Steps Plugin** (for `readJSON`)
- [x] **Credentials Binding Plugin**

---

## 🔐 Assumptions

- Jenkins stores secrets via `credentials()` securely
- Droplets expose a `/health` endpoint on port 8080
- Jenkins agent has `bash`, `curl`, and optionally `jq`

---

## ⚠️ Known Limitations

- If both droplets are down/unreachable, deployment fails.
- Jenkins agent must support Unix-like shell.

---

## ✅ Success Criteria

- ✅ New healthy droplet receives traffic via floating IP
- ✅ Old droplet is destroyed safely
- ✅ Pipeline completes all stages without failure

---

## 📘 Changelog

- **v1.0**: Initial version with fallback detection logic
- **v1.1**: Fix permission denied + fallback for missing plugins
