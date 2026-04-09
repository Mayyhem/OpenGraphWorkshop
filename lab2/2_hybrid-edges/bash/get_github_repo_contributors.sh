#!/usr/bin/env bash
REPO="${1:-SpecterOps/BloodHound}"
OUTPUT_FILE="lab2_2_${REPO//\//-}-opengraph.json"

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
CONTRIBUTORS_JSON=$(curl -s "https://api.github.com/repos/$REPO/contributors?per_page=100")

# Build initial graph with GH nodes and edges
GRAPH=$(echo "$CONTRIBUTORS_JSON" | jq --arg repo "$REPO" '{
  metadata: {source_kind: "GH"},
  graph: {
    nodes: ([{id: ("GH:" + $repo), kinds: ["GH_Repo"], properties: {name: ($repo)}}]
         + [.[] | {id: ("GH:" + .login), kinds: ["GH_User"], properties: (. + {name: .login})}]),
    edges: [.[] | {
              start: {match_by: "id", value: ("GH:" + .login)},
              end:   {match_by: "id", value: ("GH:" + $repo)},
              kind:  "GH_ContributedTo"
            }]
  }
}')

# Check each contributor for an X (Twitter) handle on their GitHub profile
for login in $(echo "$CONTRIBUTORS_JSON" | jq -r '.[].login'); do
    twitter=$(curl -s "https://api.github.com/users/${login}" | jq -r '.twitter_username // empty')
    if [ -n "$twitter" ]; then
        x_id="x:${twitter}"
        x_url="https://x.com/${twitter}"
        GRAPH=$(echo "$GRAPH" | jq \
            --arg login "$login" \
            --arg x_id "$x_id" \
            --arg x_url "$x_url" \
            --arg twitter "$twitter" '
            .graph.nodes += [{id: $x_id, kinds: ["X_User"], properties: {login: $twitter, name: $twitter, url: $x_url}}] |
            .graph.edges += [{
                start: {match_by: "id", value: ("GH:" + $login)},
                end:   {match_by: "id", value: $x_id},
                kind:  "GH_MatchesUser"
            }]')
        echo "  [+] X match: $login -> @$twitter"
    else
        echo "  [-] No X handle: $login"
    fi
done

echo "$GRAPH" > "$OUTPUT_FILE"

echo "Done! Wrote to: $OUTPUT_FILE"
