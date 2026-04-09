# Lab 2.0: Collecting an Edge

Collect contributor data from a single GitHub repository and build a graph of users and their contributions.

## Collection Concepts
- Use any protocol for collecting from your target technology (e.g., HTTP, LDAP, MSSQL, etc.). As long as you can structure the data as JSON that BloodHound can understand, it will work just fine.
- Use unique node and edge kinds for any new functionality.
- Reusing existing edge names (e.g., `AdminTo`) may result in the uploaded edges being discarded, particularly if they match a post-processed edge (i.e., edges that BloodHound creates server-side based on certain conditions, like `AdminTo`). Adhering to the schema template and prefacing edge names with the extension namespace (e.g., `OG_`) will help you not have to think about this. 
- If you are certain that the edge is not post-processed and the intent/conditions of the edge are exactly the same, you can create instances of an existing edge kind (e.g., `MemberOf` if collecting Active Directory group members and matching by `SID`).
- Edge names may only contain alphanumeric characters and underscores (`_`).
- For readability, we recommend PascalCase, a naming convention where compound words are written without spaces and each word starts with an uppercase letter (e.g., `MemberOf`, `GenericAll`).

## Schema
The schema we are creating, `schema_GH.json`, defines:

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

## References
- https://bloodhound.specterops.io/opengraph/developer/requirements
- https://bloodhound.specterops.io/resources/edges/overview