# Lab 2.0: Collecting an Edge

Collect contributor data from a single GitHub repository and build a graph of users and their contributions.

## Schema

Upload `schema_GH.json` which defines:

- **Node kinds:** `GH_Organization`, `GH_Repo`, `GH_User`
- **Relationship kind:** `GH_ContributedTo`

## Collecting Data

Scripts are provided in three languages. All default to the `SpecterOps/BloodHound` repository.

**Bash** (requires `curl` and `jq`):
```bash
bash bash/get_github_repo_contributors.sh                      # default repo
bash bash/get_github_repo_contributors.sh owner/repo            # custom repo
```

**Python** (requires `requests`):
```bash
python3 python/get_github_repo_contributors.py                  # default repo
python3 python/get_github_repo_contributors.py owner/repo       # custom repo
```

**PowerShell:**
```powershell
./powershell/Get-GitHubRepoContributors.ps1                     # default repo
./powershell/Get-GitHubRepoContributors.ps1 -Repo owner/repo    # custom repo
```

Each script outputs a JSON file named `lab2_0_<owner>-<repo>-opengraph.json`.

## Steps

1. **Upload the schema** — In BloodHound, navigate to `Administration > OpenGraph Management` and upload `schema_GH.json` 

2. **Run a collection script** — Or use the pre-collected data: `collected_data_lab2_0_SpecterOps-BloodHound-opengraph.json`

3. **Upload the collected data** — In BloodHound, navigate to `Quick Upload`, then upload `lab2_0_SpecterOps-BloodHound-opengraph.json` to populate the graph

4. **Run cypher queries** — In BloodHound, navigate to `Explore > Cypher` and either:
    
    a. Paste the following cypher query and click `Run` to explore the graph:
    ```
    MATCH p = ()-[:GH_ContributedTo]->(repo:GH_Repo)
    WHERE repo.name = "SPECTEROPS/BLOODHOUND"
    RETURN p
    ```
    
    OR
    
    b. Navigate to `Saved Queries`, click `Import`, and select and upload the ``cypher_query_4_Contributors to BloodHound GitHub Repo.json` file. Then, navigate to `Source > Personal` to try the cypher query to explore the graph.
