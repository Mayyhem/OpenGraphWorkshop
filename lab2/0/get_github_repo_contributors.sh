#!/usr/bin/env bash
REPO="${1:-SpecterOps/BloodHound}"
OUTPUT_FILE="${REPO//\//-}-opengraph.json"

# Fetch contributors and build the BloodHound payload in one pass
curl -s "https://api.github.com/repos/$REPO/contributors?per_page=100" \
  | jq --arg repo "$REPO" '{
      graph: {
        nodes: [{id: $repo, kinds: ["Repo"], properties: {name: $repo}}]
             + [.[] | {id: .login, kinds: ["User"], properties: .}],
        edges: [.[] | {
                  start: {match_by: "id", value: .login},
                  end:   {match_by: "id", value: $repo},
                  kind:  "ContributedTo"
                }]
      }
    }' > "$OUTPUT_FILE"

echo "Done! Wrote to: $OUTPUT_FILE"
