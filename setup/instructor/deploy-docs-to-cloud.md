# Deploying Documentation to the Cloud

## Overview

Deploy documentation to the cloud so remote participants can access it.

## GitHub Pages (Recommended)

### Benefits

- Free to use
- Secure with HTTPS
- Easy to configure
- Stable with a fixed URL
- Supports automatic deployment

### Limitations

> [!IMPORTANT]
> **GitHub Pages Limitations**
>
> - **Free accounts**: Repository must be **Public**
> - **GitHub Pro/Team/Enterprise**: Available for private repositories
>
> If you do not want to make hands-on materials public, use ngrok or local delivery instead.

### Prerequisites

1. Create a repository on GitHub.com (personal account) as **Public**
2. Update the local repository remote to GitHub.com

```bash
# Check current remote
git remote -v

# Update to GitHub.com repository
git remote set-url origin https://github.com/mukoubuchi/vector-search-hands-on.git

# Push
git push -u origin main
```

### Deployment Steps

#### Method 1: GitHub Actions (Automatic Deployment)

1. Create `.github/workflows/deploy-docs.yml` (already included)

2. Configure GitHub repository settings:
   - `Settings` → `Pages`
   - `Source`: Select `GitHub Actions`

3. Automatic deployment on commit & push:

   ```bash
   git add .
   git commit -m "Update docs"
   git push
   ```

4. After deployment completes, accessible at:

   ```
   https://mukoubuchi.github.io/vector-search-hands-on/
   ```

#### Method 2: Manual Deployment

```bash
# Build with MkDocs
mkdocs build

# Deploy to gh-pages branch
mkdocs gh-deploy
```

### Sharing with Participants

```
Hands-on materials: https://mukoubuchi.github.io/vector-search-hands-on/
```

---

## ngrok (Temporary Public Access)

Use when you want to instantly publish a local server.

### Installation

```bash
# macOS
brew install ngrok

# Authenticate (after registering a free account)
ngrok config add-authtoken YOUR_TOKEN
```

### Usage

```bash
# Start MkDocs
cd setup/instructor
./start-all.sh

# Start ngrok in a separate terminal
ngrok http 8001
```

Share the output URL with participants:

```
Forwarding: https://xxxx-xx-xx-xx-xx.ngrok-free.app -> http://localhost:8001
```

> [!WARNING]
> The free ngrok plan changes the URL with each session.

---

## ngrok TCP for OpenSearch (Remote Participants)

Use this only when remote participants need to reach the instructor's local OpenSearch node.
The node serves HTTPS on port `9200`; expose it with a TCP tunnel so the TLS session passes through untouched.

> [!NOTE]
> ngrok TCP endpoints may require account identity verification, such as adding a credit or debit card, even on a free account.
> If `ERR_NGROK_8013` appears, complete ngrok verification or use a VPN/Tailscale/private network, a public cloud VM, or another TCP-capable tunnel.

> [!WARNING]
> Corporate VPN or DNS security products such as Cisco Umbrella may block ngrok TCP tunnels or prevent the ngrok hostname from resolving correctly.
> Disconnecting the VPN may not be enough if Cisco Umbrella or a similar product remains active.
> If participants cannot connect through ngrok, use an organization-approved same-network, private-network, or cloud VM alternative.

> [!IMPORTANT]
> Use this as a temporary hands-on endpoint only.
> Stop the tunnel after the session, and do not publish the endpoint in long-lived materials.

### Usage

```bash
# 1. Start OpenSearch
cd setup/instructor
./start-all.sh

# 2. Start a TCP tunnel in a separate terminal
ngrok tcp 9200
```

ngrok shows a forwarding address similar to this:

```text
Forwarding  tcp://0.tcp.jp.ngrok.io:12345 -> localhost:9200
```

Share the host and port separately:

```env
OPENSEARCH_HOST=0.tcp.jp.ngrok.io
OPENSEARCH_PORT=12345
OPENSEARCH_USER=admin
OPENSEARCH_PASSWORD=<printed by start-all.sh>
```

Participants must update `OPENSEARCH_HOST`, `OPENSEARCH_PORT`, and `OPENSEARCH_PASSWORD` in `setup/participant/.env`.

### Recommended Pairing

- Documentation: GitHub Pages or `ngrok http 8001`
- OpenSearch: a private network such as Tailscale/VPN (preferred), or `ngrok tcp 9200` as a fallback. The traffic is TLS, but participants connect with certificate verification disabled, so the tunnel is encrypted without being authenticated

### If ngrok TCP Is Not Available

Choose one of these instead:

- VPN or Tailscale: Participants connect to the instructor machine's private IP, such as `10.0.1.5:9200`.
- Public cloud VM: Run OpenSearch on the VM, or forward TCP `9200` from the VM to the instructor machine.
- Managed service: Use IBM watsonx.data's managed OpenSearch with authentication and share its host/port.
- IBM Cloud Code Engine: A good fit for hosting the documentation; not a fit for the search node (see the [IBM Cloud Code Engine](#ibm-cloud-code-engine) section).

### Security Notes

- Treat the TCP URL as workshop-only connection information.
- Prefer sharing it in the live chat after the session starts.
- Stop ngrok immediately after the hands-on.
- For a longer-running public endpoint, use a cloud VM or a managed OpenSearch service with authentication, a generated password, and firewall restrictions.

---

## IBM Cloud Code Engine

A serverless container platform; useful when the organization standardizes on IBM Cloud and local container tooling is restricted (e.g. no Docker Desktop license).

### Documentation hosting (proven)

A predecessor of this hands-on served its MkDocs site from Code Engine in production, so this path is verified. Deploy the built site as a containerized static app:

```bash
# 1. Build the site (set SITE_URL to the Code Engine app URL once known)
SITE_URL=https://<app-url>/ python -m mkdocs build

# 2. Deploy as a Code Engine app serving the site/ directory
ibmcloud ce project create --name vector-search-hands-on
ibmcloud ce app create --name vector-search-docs \
  --build-source . --port 8080 --min-scale 0
```

Benefits over GitHub Pages: works with private repositories, managed HTTPS, scale-to-zero pricing. Share the generated `https://...codeengine.appdomain.cloud` URL with participants.

Lessons learned from the previous deployment, relevant when you build images **locally** instead of using `--build-source`:

- **Build AMD64 images on Apple Silicon**: Code Engine runs AMD64; an ARM64 image fails at startup with `exec format error`. Build with `podman build --platform linux/amd64 ...`.
- **Podman cannot push to IBM Cloud Container Registry directly**: ICR's identity-token authentication is incompatible with Podman. Either build with Podman, load the image into Docker, and push with the Docker CLI, or avoid local builds entirely with `--build-source` (Code Engine builds the image server-side, which also sidesteps the architecture issue).

### OpenSearch hosting

Hosting the search engine on Code Engine is not covered by this hands-on and has not been tried. Code Engine apps are single-container with ephemeral storage, which suits the documentation and not a stateful search node.

Two paths that do fit: an IBM Cloud VPC VM running the same `docker-compose` stack as the instructor setup, or IBM watsonx.data's managed OpenSearch, which participants reach by changing the `OPENSEARCH_*` values in `setup/participant/.env`. Keep Code Engine for the documentation.

---

## Local Delivery (Same Network)

Use when delivering to participants on the same network.

### Usage

```bash
# 1. Start OpenSearch and MkDocs
cd setup/instructor
./start-all.sh

# 2. Check IP address
ifconfig | grep "inet " | grep -v 127.0.0.1

# 3. Share with participants
# - OpenSearch: <IP address>:9200 (admin / password printed by start-all.sh)
# - Documentation: http://<IP address>:8001
```

### Benefits

- No internet connection required
- Low latency
- Secure environment

### Limitations

- Only accessible within the same network
- Requires instructor's machine to be running

---

## Alternatives

### Option A: Distribute Static HTML

```bash
cd /path/to/vector-search-hands-on
mkdocs build
zip -r mkdocs-site.zip site/
```

Distribute `mkdocs-site.zip` to participants and have them open `site/index.html` after extracting.

### Option B: Each Participant Runs Locally

Have participants run the following:

```bash
cd /path/to/vector-search-hands-on
python -m mkdocs serve
```

Each accesses <http://localhost:8000> on their own machine.

---

## Delivery Method Comparison

| Method | Benefits | Drawbacks | Recommended For |
|------|---------|-----------|-----------|
| **GitHub Pages** | Free, stable, HTTPS | Public repository required | When remote participants present |
| **ngrok** | Instantly public, easy | URL changes (free plan) | Temporary public access |
| **Local delivery** | Secure, low latency | Same network required | On-site only |
| **Static HTML distribution** | Works offline | Distribution effort | No internet available |
| **Each runs locally** | Fully independent | Requires environment setup | Advanced users |

---

## Recommended Workflow

### When Remote Participants Are Present

1. Publish documentation via GitHub Pages
2. Expose the instructor's OpenSearch node via `ngrok tcp 9200` only when the participant network allows it
3. If ngrok TCP is blocked, use VPN/Tailscale/private network access, a public cloud VM, a managed OpenSearch service, or have participants run the node locally

### On-site Only

1. Share documentation and OpenSearch locally
2. Access within the same network

### Hybrid

1. Publish documentation via GitHub Pages
2. On-site participants connect to the instructor's OpenSearch
3. Remote participants run their own OpenSearch
