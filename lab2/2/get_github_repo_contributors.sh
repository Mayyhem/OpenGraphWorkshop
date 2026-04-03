#!/usr/bin/env bash
ORG="${1:-SpecterOps}"
OUTPUT_FILE="${ORG}-opengraph.json"

# Fetch up to 10 public repos for the org
REPOS_JSON=$(curl -s "https://api.github.com/orgs/$ORG/repos?per_page=10")

# Collect per-repo contributor data as newline-delimited JSON blobs
ALL_CONTRIBUTORS=""
for REPO_FULL in $(echo "$REPOS_JSON" | jq -r '.[].full_name'); do
    CONTRIBUTORS=$(curl -s "https://api.github.com/repos/$REPO_FULL/contributors?per_page=100")
    # Skip if the response isn't an array (e.g. empty repo or error)
    echo "$CONTRIBUTORS" | jq -e 'type == "array"' > /dev/null 2>&1 || continue
    # Tag each contributor with their repo for edge creation
    ALL_CONTRIBUTORS+=$(echo "$CONTRIBUTORS" | jq -c --arg repo "$REPO_FULL" '[.[] | . + {_repo: $repo}]')$'\n'
done

# Build the full graph in a single jq pass
FLAT_CONTRIBUTORS=$(echo "$ALL_CONTRIBUTORS" | jq -s 'add // []')

jq -n --argjson repos "$REPOS_JSON" --argjson contributors "$FLAT_CONTRIBUTORS" '
  # Helper: keep only scalar, non-null properties
  def scalar_props: with_entries(select(.value != null and (.value | type != "object" and type != "array")));

  # Repo nodes
  ($repos | map({ id: .full_name, kinds: ["GH_Repo"], properties: scalar_props })) as $repo_nodes |

  # User nodes (deduplicated by login)
  [ $contributors | group_by(.login)[] | first |
    { id: .login, kinds: ["GH_User"], properties: (del(._repo) | scalar_props) }
  ] as $user_nodes |

  # Edges
  [ $contributors[] |
    { start: { match_by: "id", value: .login },
      end:   { match_by: "id", value: ._repo },
      kind:  "ContributedTo" }
  ] as $edges |

  { graph: { nodes: ($repo_nodes + $user_nodes), edges: $edges } }
' > "$OUTPUT_FILE"

echo "Done! Wrote to: $OUTPUT_FILE"
