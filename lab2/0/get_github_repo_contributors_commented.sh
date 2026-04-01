#!/usr/bin/env bash
REPO="${1:-SpecterOps/BloodHound}"
OUTPUT_FILE="${REPO//\//-}-opengraph.json"

# Fetch contributors and pipe the JSON into jq to reshape it
curl -s "https://api.github.com/repos/$REPO/contributors?per_page=100" \
  | jq --arg repo "$REPO" '          # --arg passes $REPO into jq as $repo
    {
      graph: {
        nodes:
          # First, create one node for the repo itself
          [{id: $repo, kinds: ["Repo"], properties: {name: $repo}}]

          # Then append (+) a node for each contributor in the array
          # .[] loops over every item; we reshape each one into a node
          # the bare "." in "properties: ." means "the entire original object" —
          # so every field from the API response becomes a property
          + [.[] | {id: .login, kinds: ["User"], properties: .}],

        edges:
          # For each contributor, create an edge from the user to the repo
          [.[] | {
            start: {match_by: "id", value: .login},    # from: this contributor
            end:   {match_by: "id", value: $repo},     # to: the repo
            kind:  "ContributedTo"
          }]
      }
    }' > "$OUTPUT_FILE"

echo "Done! Wrote to: $OUTPUT_FILE"
