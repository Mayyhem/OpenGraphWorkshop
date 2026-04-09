# Lab 2.1: Expanding the Graph

Expand from a single repository to multiple repositories within a GitHub organization, building a larger contributor graph.

## What's Different from Lab 2.0

- Fetches up to 5 public repositories for an organization
- Collects contributors across all repositories
- Deduplicates users who contribute to multiple repos

## Collecting Data

Scripts are provided in three languages. All default to the `SpecterOps` organization.

**Bash** (requires `curl` and `jq`):
```bash
bash bash/get_github_repo_contributors.sh                  # default org
bash bash/get_github_repo_contributors.sh myorg             # custom org
```

**Python** (requires `requests`):
```bash
python3 python/get_github_repo_contributors.py              # default org
python3 python/get_github_repo_contributors.py myorg        # custom org
```

**PowerShell:**
```powershell
./powershell/Get-GitHubRepoContributors.ps1                 # default org
./powershell/Get-GitHubRepoContributors.ps1 -Org myorg      # custom org
```

Each script outputs a JSON file named `lab2_1_<org>-opengraph.json`.

## Steps

1. **Run a collection script** — Or use the pre-collected data: `collected_data_lab2_1_SpecterOps-opengraph.json`

2. **Upload the collected data** — In BloodHound, navigate to `Quick Upload`, then upload `lab2_1_SpecterOps-opengraph.json` to populate the graph

3. **Run cypher queries** — In BloodHound, navigate to `Explore > Cypher` and either:
    
    a. Paste the following cypher query and click `Run` to explore the graph:
    ```
    MATCH p = ()-[:GH_ContributedTo]->()
    RETURN p
    ```
    
    OR
    
    b. Navigate to `Saved Queries`, click `Import`, and select and upload the `cypher_query_5_Contributors to Repos in Organization.json` file. Then, navigate to `Source > Personal` to try the cypher query to explore the graph.