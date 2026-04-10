#!/usr/bin/env python3
import argparse, json, requests

parser = argparse.ArgumentParser()
parser.add_argument("org", nargs="?", default="SpecterOps")
args = parser.parse_args()

org = args.org
output_file = f"lab2_1_{org}-opengraph.json"

# Fetch org details and up to 5 public repos
org_info = requests.get(f"https://api.github.com/orgs/{org}").json()
repos = requests.get(f"https://api.github.com/orgs/{org}/repos?per_page=5").json()

# Start with the organization node
org_props = {k: v for k, v in org_info.items() if not isinstance(v, (dict, list)) and v is not None}
nodes = [{"id": f"GH:{org}", "kinds": ["GH_Organization"], "properties": org_props}]
edges = []

for repo in repos:
    repo_full = repo["full_name"]
    # Only keep scalar (string/number/bool) properties — nested dicts/lists fail schema validation
    repo_props = {k: v for k, v in repo.items() if not isinstance(v, (dict, list)) and v is not None}
    nodes.append({"id": f"GH:{repo_full}", "kinds": ["GH_Repo"], "properties": repo_props})
    edges.append({
        "start": {"match_by": "id", "value": f"GH:{org}"},
        "end":   {"match_by": "id", "value": f"GH:{repo_full}"},
        "kind":  "GH_Contains",
    })

    # Fetch contributors for each repo
    contributors = requests.get(f"https://api.github.com/repos/{repo_full}/contributors?per_page=100").json()
    if not isinstance(contributors, list):
        continue

    for c in contributors:
        # Only add the user node once (they may contribute to multiple repos)
        if not any(n["id"] == f"GH:{c['login']}" for n in nodes):
            user_props = {k: v for k, v in c.items() if not isinstance(v, (dict, list)) and v is not None}
            user_props["name"] = c['login']
            nodes.append({"id": f"GH:{c['login']}", "kinds": ["GH_User"], "properties": user_props})
        edges.append({
            "start": {"match_by": "id", "value": f"GH:{c['login']}"},
            "end":   {"match_by": "id", "value": f"GH:{repo_full}"},
            "kind":  "GH_ContributedTo",
        })

with open(output_file, "w", encoding="utf-8") as f:
    json.dump({"metadata": {"source_kind": "GH"}, "graph": {"nodes": nodes, "edges": edges}}, f, indent=2)

print(f"Done! Wrote {len(nodes)} nodes and {len(edges)} edges to: {output_file}")
