#!/usr/bin/env python3
import argparse, json, requests

parser = argparse.ArgumentParser()
parser.add_argument("repo", nargs="?", default="SpecterOps/BloodHound")
args = parser.parse_args()

repo = args.repo
output_file = f"{repo.replace('/', '-')}-opengraph.json"

contributors = requests.get(f"https://api.github.com/repos/{repo}/contributors?per_page=100").json()

# Start the graph with the repo as the only node
nodes = [{"id": repo, "kinds": ["GH_Repo"], "properties": {"name": repo}}]
edges = []

# Add each contributor as a node, and draw an edge from them to the repo
for c in contributors:
    nodes.append({"id": c["login"], "kinds": ["GH_User"], "properties": c})
    edges.append({
        "start": {"match_by": "id", "value": c["login"]},
        "end":   {"match_by": "id", "value": repo},
        "kind":  "ContributedTo",
    })
    # Connect this User to an AD User node by name
    edges.append({
        "start": {"match_by": "id",   "value": c["login"]},
        "end":   {"match_by": "name", "value": c["login"]},
        "kind":  "MatchesADUser",
    })

# Wrap in the BloodHound payload format and save to disk
with open(output_file, "w", encoding="utf-8") as f:
    json.dump({"graph": {"nodes": nodes, "edges": edges}}, f, indent=2)

print(f"Done! Wrote {len(nodes)} nodes and {len(edges)} edges to: {output_file}")
