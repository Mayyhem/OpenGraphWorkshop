# Lab 2.2: Hybrid Edges

Link GitHub users to their X (Twitter) profiles by looking up each contributor's GitHub profile for a `twitter_username` field. This demonstrates cross-source graph analysis.

## Concepts
- To create a hybrid edge, leverage the `match_by` edge property to connect two nodes from disparate technologies by their `id` (or other properties):
    ```
    {
    "start": {
        "match_by": "id",
        "value": "GH:Mayyhem"
    },
    "end": {
        "match_by": "id",
        "value": "x:_Mayyhem"
    },
    "kind": "GH_MatchesUser"
    }
    ```

## Schemas

Two schemas need to be uploaded:

- **`schema_GH_updated.json`** — Updated GitHub schema (v0.0.2) adding the `GH_MatchesUser` relationship kind
- **`schema_X.json`** — New X (Twitter) schema defining the `X_User` node kind

## Collecting Data

Scripts are provided in three languages. All default to the `SpecterOps/BloodHound` repository.

> **Note:** These scripts make an additional API call per contributor to fetch their GitHub profile. This may hit GitHub API rate limits for repos with many contributors.

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

Each script outputs a JSON file named `lab2_2_<owner>-<repo>-opengraph.json` and logs X matches as it runs:
```
  [+] X match: username -> @twitter_handle
  [-] No X handle: username
```

## Steps

1. **Upload the schemata** — In BloodHound, navigate to `Administration > OpenGraph Management` and upload both `schema_GH_updated.json` and `schema_X.json`

2. **Run a collection script** — Or use the pre-collected data: `collected_data_lab2_2_SpecterOps-BloodHound-opengraph.json`

3. **Upload the collected data** — In BloodHound, navigate to `Quick Upload`, then upload `lab2_2_SpecterOps-BloodHound-opengraph.json` to populate the graph

4. **Run cypher queries** — In BloodHound, navigate to `Explore > Cypher` and either:
    
    a. Paste each of the three cypher queries and click `Run` to explore the graph:

    GitHub Users Matching X Users:
    ```
    MATCH p = ()-[:GH_MatchesUser]->()
    RETURN p
    ```
    X Users Matching Contributors to GitHub Repos:
    ```
    MATCH p0 = 
    (user:GH_User)-[:GH_ContributedTo]->(:GH_Repo)
    MATCH p1 = 
    (user)-[:GH_MatchesUser]->(:X_User)
    RETURN p0,p1
    ```
    All the Things:
    ```
    MATCH p = ()-[]-()
    RETURN p
    ```
    
    OR
    
    b. Navigate to `Saved Queries`, click `Import`, and select and upload the `cypher_query*` files. Then, navigate to `Source > Personal` to try each of the three cypher queries to explore the graph.

## References
- https://bloodhound.specterops.io/opengraph/developer/schema#edge-endpoint-matching
