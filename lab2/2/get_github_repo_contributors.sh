#!/usr/bin/env bash
ORG="${1:-SpecterOps}"
OUTPUT_FILE="${ORG}-opengraph.json"

# Fetch up to 10 public repos for the org
REPOS_JSON=$(curl -s "https://api.github.com/orgs/$ORG/repos?per_page=10")

NODES=$(echo '[]')
EDGES=$(echo '[]')

# Loop through each repo
for REPO_FULL in $(echo "$REPOS_JSON" | jq -r '.[].full_name'); do

    # Add a Repo node
    NODES=$(echo "$NODES" | jq --argjson repo "$(echo "$REPOS_JSON" | jq '.[] | select(.full_name == "'"$REPO_FULL"'")')" \
      '. + [{ id: $repo.full_name, kinds: ["Repo"], properties: ($repo | with_entries(select(.value != null and (.value | type != "object" and type != "array")))) }]')

    # Fetch contributors for this repo
    CONTRIBUTORS=$(curl -s "https://api.github.com/repos/$REPO_FULL/contributors?per_page=100")

    # Skip if the response isn't an array (e.g. empty repo or error)
    if ! echo "$CONTRIBUTORS" | jq -e 'type == "array"' > /dev/null 2>&1; then
        continue
    fi

    # Loop through each contributor
    for LOGIN in $(echo "$CONTRIBUTORS" | jq -r '.[].login'); do

        # Add a User node (only if we haven't seen this user yet)
        if ! echo "$NODES" | jq -e --arg id "$LOGIN" 'any(.[]; .id == $id)' > /dev/null 2>&1; then
            NODES=$(echo "$NODES" | jq --argjson c "$(echo "$CONTRIBUTORS" | jq '.[] | select(.login == "'"$LOGIN"'")')" \
              '. + [{ id: $c.login, kinds: ["User"], properties: ($c | with_entries(select(.value != null and (.value | type != "object" and type != "array")))) }]')
        fi

        # Add a ContributedTo edge from the user to the repo
        EDGES=$(echo "$EDGES" | jq --arg login "$LOGIN" --arg repo "$REPO_FULL" \
          '. + [{ start: { match_by: "id", value: $login }, end: { match_by: "id", value: $repo }, kind: "ContributedTo" }]')
    done
done

# Combine nodes and edges into the final graph and write to disk
jq -n --argjson nodes "$NODES" --argjson edges "$EDGES" \
  '{ graph: { nodes: $nodes, edges: $edges } }' > "$OUTPUT_FILE"

echo "Done! Wrote to: $OUTPUT_FILE"
