# xayn-kube

## Task

Create a solution described below.

### Requirements

* **Estimated completion time: 3 hours**
* Deploy a Traefik ingress controller that routes traffic to a secondary pod serving a static site (e.g., Nginx).
* Support two environments: **dev** and **prod**.
* The static site should display a message injected via an environment variable stored as a secret:
  `Hello World! I am on [dev|prod]. This is my [secret]`
* Serve the site over **HTTPS** using a self-signed certificate.
* Use **Kubernetes** and **Helm**; host the code in a public Git repository.
* Provide bootstrap scripts to deploy the stack locally with **Minikube** or a similar tool.

### Optional enhancements

* Automated certificates via **Let’s Encrypt** and a custom domain.
* Implement liveness and readiness probes.
* Terraform bootstrap for managed Kubernetes clusters (e.g., GKE or EKS).

## Ideal solution

* Encrypt secrets using **SOPS** or the **External Secrets Operator**.
* Deploy with **Flux** to synchronize changes from the Git repository.
* Use **ExternalDNS** for dynamic DNS record management.
* Run on managed Kubernetes platforms such as **EKS** or **GKE**.
* Architect for high availability with multiple nodes.
* Store Terraform state remotely, for example in an **S3** bucket.

## Current solution

Due to time constraints, the current implementation does not cover the full ideal solution. It includes:

* **Terraform** code provisioning infrastructure on **Hetzner** Cloud, chosen for cost-effectiveness compared to AWS.
* Required "secrets" are exposed via a **ConfigMap** instead of Kubernetes `Secret` with SOPS or External Secrets Operator, as **these secrets are directly rendered on the landing page**. Therefore, using Kubernetes Secrets does not make sense.. For sensitive credentials (e.g., API keys), Kubernetes `Secret` objects encrypted with SOPS or managed by the External Secrets Operator are recommended.
* Nginx passthrough proxy (offloading TCP connections to backend).
* Two domains managed on DuckDNS.
* Certificates provisioned using Let’s Encrypt.
* Local cluster setup using Minikube.

### Terraform variables

* `hcloud_token` — Hetzner Cloud API token
* `duckdns_token` — DuckDNS API token

### Access URLs

* **Production:** [https://prod-xayn.duckdns.org](https://prod-xayn.duckdns.org)
* **Development:** [https://dev-xayn.duckdns.org](https://dev-xayn.duckdns.org)
