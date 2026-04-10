# Install BloodHound CE with OpenGraph

Automated scripts to install BloodHound Community Edition with the OpenGraph extension enabled.

## Prerequisites

| Platform | Requirement |
|----------|-------------|
| Linux    | [Docker Engine](https://docs.docker.com/engine/install/) |
| macOS    | [Docker Desktop for Mac](https://docs.docker.com/desktop/setup/install/mac-install/) |
| Windows  | [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/) |

## Usage

**Linux:**
```bash
bash LINUX_install-bhce-pathfinding.sh
```

**macOS (Apple Silicon):**
```bash
bash MAC_install-bhce-pathfinding.sh
```

**Windows (PowerShell):**
```powershell
.\WINDOWS_install-bhce-pathfinding.ps1
```

## What the Scripts Do

1. Download `bloodhound-cli` v0.2.0
2. Set the graph driver to PostgreSQL (`pg`)
3. Remove the Neo4j `graph-db` service from `docker-compose.yml`
4. Install BloodHound CE
5. Enable the `opengraph_extension_management` feature flag in PostgreSQL

> **Windows note:** You will be prompted to overwrite YAML files twice. Answer **Y** the first time and **N** the second time.

After installation, BloodHound CE will be running with OpenGraph support at `http://localhost:8080`.

## References
- https://bloodhound.specterops.io/opengraph/developer/requirements
