#!/usr/bin/env bash
REPO="${1:-SpecterOps/BloodHound}"
OUTPUT_FILE="lab2_0_${REPO//\//-}-opengraph.json"

# If the repo arg contains a slash (e.g. "SpecterOps/BloodHound"), extract the org
ORG=""
if [[ "$REPO" == */* ]]; then
    ORG="${REPO%%/*}"
    ORG_JSON=$(curl -s "https://api.github.com/orgs/$ORG")
fi

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
  | jq --arg repo "$REPO" --arg org "$ORG" --argjson org_info "${ORG_JSON:-null}" '
      # Helper: keep only scalar, non-null properties
      def scalar_props: with_entries(select(.value != null and (.value | type != "object" and type != "array")));

      # Organization node + GH_Contains edge (only when org is present)
      (if $org != "" then [{id: ("GH:" + $org), kinds: ["GH_Organization"], properties: ($org_info | scalar_props)}] else [] end) as $org_nodes |
      (if $org != "" then [{start: {match_by: "id", value: ("GH:" + $org)}, end: {match_by: "id", value: ("GH:" + $repo)}, kind: "GH_Contains"}] else [] end) as $contains_edges |

      {
      metadata: {source_kind: "GH"},
      graph: {
        nodes:
          ($org_nodes
          + [{id: ("GH:" + $repo), kinds: ["GH_Repo"], properties: {name: ($repo)}}]
          + [.[] | {id: ("GH:" + .login), kinds: ["GH_User"], properties: (. + {name: .login})}]),
        edges:
          ($contains_edges
          + [.[] | {
            start: {match_by: "id", value: ("GH:" + .login)},
            end:   {match_by: "id", value: ("GH:" + $repo)},
            kind:  "GH_ContributedTo"
          }])
      }
    }' > "$OUTPUT_FILE"

echo "Done! Wrote to: $OUTPUT_FILE"
