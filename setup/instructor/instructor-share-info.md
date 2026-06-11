# Vector Search Hands-on Instructor Guide

## Quick Start

### 1. Start Environment

```bash
cd setup/instructor
./start-all.sh
```

This starts the following:

- **Milvus environment** (etcd, MinIO, Milvus)
- **Local documentation server** (<http://localhost:8001>)

On first start the script also **generates random Milvus and MinIO passwords** (replacing the `root/Milvus` default), prints the Milvus password, and stores both in `setup/instructor/.env`. Share the printed Milvus password with participants. To look it up later:

```bash
grep '^MILVUS_PASSWORD=' setup/instructor/.env
```

> [!NOTE]
> **Why use port 8001**
>
> - Due to docker-compose port mapping (`8001:8000`), the instructor accesses on port 8001
> - **All participants on the same network can access documentation at `instructor IP:8001`**
> - Port 8000 may conflict with participants' FastAPI apps, so port 8001 is used
> - This eliminates the need for each participant to start their own documentation server
>
> [!IMPORTANT]
> **Note when editing documentation**
>
> **Due to macOS Docker Desktop limitations, automatic file change detection does not work in the Docker-based MkDocs (port 8001).**
>
> ### Container version vs Development version comparison
>
> | Item | Container version (port 8001) | Development version (port 8000) |
> |------|------------------------|---------------------|
> | **How to start** | Auto-start with `./start-all.sh` | Manual start with `python -m mkdocs serve` |
> | **Purpose** | Sharing with participants, stable delivery | Document editing work |
> | **Auto-reload** | Not available (macOS Docker Desktop limitation) | Available |
> | **Reflecting changes** | Requires container restart or manual browser reload | Reflected immediately |
> | **Network sharing** | Available (instructor IP:8001) | Available (instructor IP:8000) |
> | **Recommended use** | Sharing with participants during live hands-on | Pre-preparation, document editing |
>
> ### Recommended usage
>
> 1. **When editing documents** (development)
>
>    ```bash
>    # Run from project root (where mkdocs.yml is located)
>    cd /path/to/vector-search-hands-on
>    python -m mkdocs serve
>    ```
>
>    - Access at: <http://localhost:8000>
>    - File changes are reflected immediately
>    - Auto-reload works correctly
>    - **Important**: Run from the directory containing `mkdocs.yml`
>
> 2. **When sharing with participants** (production)
>
>    ```bash
>    cd setup/instructor
>    ./start-all.sh
>    ```
>
>    - Access at: `http://localhost:8001` or `http://instructor-IP:8001`
>    - All participants on the network can access
>    - After file changes, **manually reload browser** is required

### 2. Check Instructor IP Address

```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1
# Use the first IP address shown (e.g. 10.0.1.5)
```

---

## Information to Share with Participants

### Required Information

```
MILVUS_HOST=<instructor IP address>          # e.g. 10.0.1.5
MILVUS_PASSWORD=<printed by start-all.sh>    # stored in setup/instructor/.env
```

### Documentation URL

For on-site sessions (office, conference room, etc.) on the same WiFi/network:

```
http://<instructor IP address>:8001  # e.g. http://10.0.1.5:8001
```

#### Benefits

- Easy setup (`./start-all.sh` only)
- Fast access within the network

#### Limitations

- Only accessible to participants on the same network

> [!IMPORTANT]
> **Important**
>
> - Share the **IP address, Milvus password (printed by `start-all.sh`), and documentation URL** with participants
> - Each participant must also set their own unique `COLLECTION_NAME` (e.g. `products_taro`) in `.env` — the Milvus instance is shared, and inserting sample data into the same collection overwrites other participants' data
> - Other settings (PORT, USER, etc.) are already configured in `.env.example`

### Additional: Other Configuration Values (No Need to Share)

The following settings are already configured in `.env.example`, so there is no need to share them with participants:

```env
MILVUS_PORT=19530
MILVUS_USER=root
EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
PARTICIPANT_LANGUAGE=en  # vector-search-builder-en.zip uses en, vector-search-builder-ja.zip uses ja
```

`MILVUS_PASSWORD` and `COLLECTION_NAME` are the exceptions: participants replace the template placeholders with the distributed password and their own unique collection name (the scripts refuse to run while a placeholder is unchanged).

---

## Participant Announcement (Copy-Paste Ready)

### For On-site Sessions

Copy the following and replace **\<instructor IP address\>** with the actual value before sending.

```text
[Vector Search Hands-on Connection Information]

■ Milvus Connection Information
MILVUS_HOST=<instructor IP address>          # e.g. 10.0.1.5
MILVUS_PASSWORD=<printed by start-all.sh>

■ Documentation URL
http://<instructor IP address>:8001  # e.g. http://10.0.1.5:8001

[Setup Steps]
1. Extract the zip file for your language: vector-search-builder-en.zip or vector-search-builder-ja.zip
2. Open the project folder in IBM Bob IDE
3. Copy setup/participant/.env.example to setup/participant/.env
4. Open setup/participant/.env and change MILVUS_HOST and MILVUS_PASSWORD to the values above
5. In the same file, change COLLECTION_NAME to a name unique to you (e.g. products_taro)
6. Reload IBM Bob (Cmd+Shift+P -> Developer: Reload Window)
7. Confirm "Vector Search Builder" appears in the Mode selector and select it
8. Install dependencies: pip install -r setup/participant/requirements.txt
9. Run connection test: python setup/participant/test_connection.py

[Important]
- Change MILVUS_HOST, MILVUS_PASSWORD, and COLLECTION_NAME (use a collection name unique to you; Milvus is shared)
- Other settings do not need to be changed (already set to correct values)
- `PARTICIPANT_LANGUAGE` is already set by the selected zip (`en` for English, `ja` for Japanese)
```

### For Remote Sessions with ngrok TCP

Use this **only as a fallback** when remote participants cannot join a private network (Tailscale, VPN) and no organization-approved cloud endpoint is available.

> [!WARNING]
> Milvus gRPC traffic is **not TLS-encrypted**: the password and data transit the ngrok tunnel in cleartext on the public internet. Use this only for throwaway hands-on data and stop the tunnel immediately after the session. Prefer a private network whenever possible.

> [!NOTE]
> Authentication itself is enforced. `start-all.sh` already replaced the default root password with a generated one (stored in `setup/instructor/.env`); share that password with participants.

> [!WARNING]
> Corporate VPN or DNS security products such as Cisco Umbrella may block ngrok TCP tunnels or prevent the ngrok hostname from resolving correctly.
> Disconnecting the VPN may not be enough if Cisco Umbrella or a similar product remains active.
> If participants cannot connect through ngrok, use an organization-approved same-network, private-network, or cloud VM alternative.

Start the Milvus TCP tunnel with:

```bash
ngrok tcp 19530
```

If ngrok shows the following:

```text
Forwarding  tcp://0.tcp.jp.ngrok.io:12345 -> localhost:19530
```

share this message with participants:

```text
[Vector Search Hands-on Connection Information]

■ Milvus Connection Information
MILVUS_HOST=0.tcp.jp.ngrok.io
MILVUS_PORT=12345
MILVUS_USER=root
MILVUS_PASSWORD=<printed by start-all.sh>

■ Documentation URL
<GitHub Pages URL or ngrok documentation URL>

[Setup Steps]
1. Extract the zip file for your language: vector-search-builder-en.zip or vector-search-builder-ja.zip
2. Open the project folder in IBM Bob IDE
3. Copy setup/participant/.env.example to setup/participant/.env
4. Open setup/participant/.env and update MILVUS_HOST, MILVUS_PORT, and MILVUS_PASSWORD to the values above
5. In the same file, change COLLECTION_NAME to a name unique to you (e.g. products_taro)
6. Reload IBM Bob (Cmd+Shift+P -> Developer: Reload Window)
7. Confirm "Vector Search Builder" appears in the Mode selector and select it
8. Install dependencies: pip install -r setup/participant/requirements.txt
9. Run connection test: python setup/participant/test_connection.py

[Important]
- Remote participants must update MILVUS_HOST, MILVUS_PORT, MILVUS_PASSWORD, and COLLECTION_NAME
- Use a collection name unique to you (Milvus is shared by all participants)
- Do not include tcp:// in MILVUS_HOST
- Stop the ngrok TCP tunnel after the hands-on
```

---

## Instructor Checklist

### Pre-preparation

- [ ] Container runtime started (Docker Desktop or `colima start`)
- [ ] Milvus environment started (`./start-all.sh`)
- [ ] IP address confirmed
- [ ] Connection test successful

### Participant Support

- [ ] Downloaded the participant zips from the [latest release assets](https://github.com/mukoubuchi/vector-search-hands-on/releases/latest) (or built them with `./build-participant-zips.sh`)
- [ ] Distributed the minimal participant zip for each language (`vector-search-builder-en.zip` or `vector-search-builder-ja.zip`)
- [ ] Shared connection information (IP address + documentation URL)
- [ ] Confirmed participants completed connection test

### Troubleshooting Preparation

- [ ] Firewall settings checked (port 19530 open)
- [ ] Participant network connectivity confirmed

---

## Troubleshooting

### Cannot Connect

#### 1. Check Firewall

```bash
# macOS
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

#### 2. Check Port

```bash
lsof -i :19530
```

#### 3. Check Docker

```bash
docker ps
# Verify milvus-standalone and vector-search-docs are Running
```

### Model Download is Slow

On first run, downloading the model from Hugging Face (approximately 460 MB) takes time.

#### Workaround

- Encourage participants to pre-download the model
- Pre-download on the instructor's machine and share the cache

---

## FAQ

### Q1: Can the container version (8001) and development version (8000) run simultaneously?

**A: Yes, they can run simultaneously. There is no conflict because the ports differ.**

#### Benefits of simultaneous operation

- Participants can still access port 8001 while editing documents
- Editing work (8000) and delivery (8001) can proceed in parallel
- Confirm edits on port 8000 while participants view the stable version on port 8001

#### Drawbacks of simultaneous operation

- **Resource consumption**: Serving the same content with two processes (memory/CPU usage)
- **Risk of confusion**: May lose track of which port is being used
- **Maintainability**: Need to manage two servers

#### Recommended operation

**Normal (live hands-on):**

```bash
./start-all.sh  # Start only container version (8001)
```

- Participants access `http://instructor-IP:8001`
- No document editing (focus on stable delivery)

**When document editing is needed:**

```bash
# Move to project root (where mkdocs.yml is located)
cd /path/to/vector-search-hands-on

# Foreground execution (occupies terminal)
python -m mkdocs serve

# Background execution (frees up terminal)
python -m mkdocs serve &
```

**How to stop:**

```bash
# Foreground execution
Ctrl+C

# Background execution
cd setup/instructor && ./stop-all.sh  # Auto-detects and stops ports 8000 and 8002

# Manual stop
kill $(lsof -ti:8000)
kill $(lsof -ti:8002)
```

- Instructor confirms edits at `http://localhost:8000`
- Participants continue using <http://instructor IP:8001>
- After editing, restart container to reflect changes on port 8001

**Conclusion**: Technically simultaneous operation is possible, but **normally the container version (8001) alone is sufficient**.

### Q2: Will participants see documentation updates automatically after I edit?

**A: No, automatic updates do not work in the container version (8001).**

- **Container version (8001)**: Automatic file change detection does not work (macOS Docker Desktop limitation)
  - Workaround: Restart container or ask participants to manually reload browser
- **Development version (8000)**: Auto-reload works correctly
  - Changes are reflected immediately when files are saved

### Q3: I get "Config file 'mkdocs.yml' does not exist" error when running `python -m mkdocs serve`

**A: Run from the directory containing `mkdocs.yml` (project root).**

```bash
# Check current directory
pwd

# Move to project root
cd /path/to/vector-search-hands-on

# Verify mkdocs.yml exists
ls mkdocs.yml

# Start development version
python -m mkdocs serve
```

**If running from setup/instructor/ directory:**

```bash
cd ../..  # Move to project root
python -m mkdocs serve
```

### Q4: How do I stop the development version (8000) or FastAPI demo (8002) when started in the background?

**A: There are 3 methods.**

1. **Run `./stop-all.sh` (recommended)**

   ```bash
   cd setup/instructor
   ./stop-all.sh
   ```

   - Auto-detects and stops ports 8000 and 8002
   - **Can stop regardless of foreground/background**
   - Also stops container version (8001) simultaneously

2. **Manually stop the process**

   ```bash
   kill $(lsof -ti:8000)
   kill $(lsof -ti:8002)
   ```

   - Identifies and stops the process using port 8000 or 8002

3. **Check process ID then stop**

   ```bash
   lsof -i:8000  # Check process ID
   lsof -i:8002  # Check process ID
   kill <PID>    # Stop with identified PID
   ```

**Note**: For foreground execution, stop with `Ctrl+C`.

### Q5: What happens if a participant accidentally accesses port 8000?

**A: A connection error will occur if the development version (8000) is not running.**

- The development version only runs when started manually with `python -m mkdocs serve`
- Always direct participants to **8001**
- Port 8000 is exclusively for the instructor's document editing

---

## Environment Information

### Fixed Settings (Already configured in `.env.example`)

- Milvus port: `19530`
- Credentials: `root` / password generated by `start-all.sh` (authentication is enforced; the value is stored in `setup/instructor/.env`)
- Embedding model: `paraphrase-multilingual-MiniLM-L12-v2` (the vector dimension is detected from the model)
- Collection name: each participant sets their own unique `COLLECTION_NAME`
- Participant language: set by zip package (`en` / `ja`)
- Python: `3.9` or higher
- Milvus: `2.6.18` / pymilvus: `2.6.15` / sentence-transformers: `5.5.1`

### Environment-dependent (Verify each time)

- **Instructor IP address** (changes when switching WiFi, wired/wireless, or VPN connection)

### Local environment (Instructor side only)

- Milvus: `localhost:19530`
- Documentation: `http://localhost:8001` (docker-compose port mapping)
  - If participants start their own: `http://localhost:8000`

---

**Note**: This file is for instructors only. Do not distribute to participants.
