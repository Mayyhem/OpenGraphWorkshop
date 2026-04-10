#!/usr/bin/env python3
import argparse, json, requests

parser = argparse.ArgumentParser()
parser.add_argument("repo", nargs="?", default="SpecterOps/BloodHound")
args = parser.parse_args()

repo = args.repo
output_file = f"lab2_0_{repo.replace('/', '-')}-opengraph.json"

contributors = requests.get(f"https://api.github.com/repos/{repo}/contributors?per_page=100").json()

# Start the graph with the repo node
nodes = [{"id": f"GH:{repo}", "kinds": ["GH_Repo"], "properties": {"name": repo}}]
edges = []

# If the repo contains an org (e.g. "SpecterOps/BloodHound"), add the org node and a GH_Contains edge
if "/" in repo:
    org = repo.split("/")[0]
    org_info = requests.get(f"https://api.github.com/orgs/{org}").json()
    org_props = {k: v for k, v in org_info.items() if not isinstance(v, (dict, list)) and v is not None}
    nodes.insert(0, {"id": f"GH:{org}", "kinds": ["GH_Organization"], "properties": org_props})
    edges.append({
        "start": {"match_by": "id", "value": f"GH:{org}"},
        "end":   {"match_by": "id", "value": f"GH:{repo}"},
        "kind":  "GH_Contains",
    })

# Add each contributor as a node, and draw an edge from them to the repo
for c in contributors:
    nodes.append({"id": f"GH:{c['login']}", "kinds": ["GH_User"], "properties": {**c, "name": c['login']}})
    edges.append({
        "start": {"match_by": "id", "value": f"GH:{c['login']}"},
        "end":   {"match_by": "id", "value": f"GH:{repo}"},
        "kind":  "GH_ContributedTo",
    })

# Wrap in the BloodHound payload format and save to disk
with open(output_file, "w", encoding="utf-8") as f:
    json.dump({"metadata": {"source_kind": "GH"}, "graph": {"nodes": nodes, "edges": edges}}, f, indent=2)

print(f"Done! Wrote {len(nodes)} nodes and {len(edges)} edges to: {output_file}")