#!/usr/bin/env python3
import argparse, json, requests

parser = argparse.ArgumentParser()
parser.add_argument("org", nargs="?", default="SpecterOps")
args = parser.parse_args()

org = args.org
output_file = f"{org}-opengraph.json"

# Fetch up to 10 public repos for the org
repos = requests.get(f"https://api.github.com/orgs/{org}/repos?per_page=10").json()

nodes = []
edges = []

for repo in repos:
    repo_full = repo["full_name"]
    # Only keep scalar (string/number/bool) properties — nested dicts/lists fail schema validation
    repo_props = {k: v for k, v in repo.items() if not isinstance(v, (dict, list)) and v is not None}
    nodes.append({"id": repo_full, "kinds": ["GH_Repo"], "properties": repo_props})

    # Fetch contributors for each repo
    contributors = requests.get(f"https://api.github.com/repos/{repo_full}/contributors?per_page=100").json()
    if not isinstance(contributors, list):
        continue

    for c in contributors:
        # Only add the user node once (they may contribute to multiple repos)
        if not any(n["id"] == c["login"] for n in nodes):
            user_props = {k: v for k, v in c.items() if not isinstance(v, (dict, list)) and v is not None}
            nodes.append({"id": c["login"], "kinds": ["GH_User"], "properties": user_props})
        edges.append({
            "start": {"match_by": "id", "value": c["login"]},
            "end":   {"match_by": "id", "value": repo_full},
            "kind":  "ContributedTo",
        })

with open(output_file, "w", encoding="utf-8") as f:
    json.dump({"graph": {"nodes": nodes, "edges": edges}}, f, indent=2)

print(f"Done! Wrote {len(nodes)} nodes and {len(edges)} edges to: {output_file}")
