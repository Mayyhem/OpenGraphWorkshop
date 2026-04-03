#!/usr/bin/env bash
REPO="${1:-SpecterOps/BloodHound}"
OUTPUT_FILE="${REPO//\//-}-opengraph.json"

# Fetch contributors and pipe the JSON into jq to reshape it
#
# jq notes:
#   --arg repo "$REPO"  passes the shell variable $REPO into jq as $repo
#
#   nodes array:
#     - First element: one node for the repo itself
#     - Then we append (+) a node for each contributor in the array
#       .[] loops over every item; we reshape each one into a node
#       the bare "." in "properties: ." means "the entire original object" —
#       so every field from the API response becomes a property
#
#   edges array:
#     - For each contributor, create an edge from the user to the repo
#       start = this contributor, end = the repo
curl -s "https://api.github.com/repos/$REPO/contributors?per_page=100" \
  | jq --arg repo "$REPO" '{
      graph: {
        nodes: ([{id: ($repo), kinds: ["GH_Repo"], properties: {name: ($repo)}}]
             + [.[] | {id: .login, kinds: ["GH_User"], properties: .}]),
        edges: [.[] | {
                  start: {match_by: "id", value: .login},
                  end:   {match_by: "id", value: ($repo)},
                  kind:  "ContributedTo"
                },
                {
                  start: {match_by: "id",   value: .login},
                  end:   {match_by: "name", value: .login},
                  kind:  "MatchesADUser"
                }]
      }
    }' > "$OUTPUT_FILE"

echo "Done! Wrote to: $OUTPUT_FILE"
