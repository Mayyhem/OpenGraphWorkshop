#!/bin/bash

# Prerequisites: Docker Desktop for Mac
# Install via Homebrew:
#   brew install --cask docker
# Or download from: https://docs.docker.com/desktop/setup/install/mac-install/
# After installation, ensure Docker Desktop is running before executing this script.
cd /tmp && \
curl -L -o bloodhound-cli-darwin-arm64.tar.gz https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-darwin-arm64.tar.gz && \
tar xvzf bloodhound-cli-darwin-arm64.tar.gz && \
./bloodhound-cli config set graph_driver pg && \
yes | ./bloodhound-cli check && \
sed -i '.bak' '/^  graph-db:/,/^  bloodhound:/{ /^  bloodhound:/!d; }; /neo4j-data/d; /graph-db/{N;d;}' ~/Library/Application\ Support/bloodhound/docker-compose.yml && \
yes n | ./bloodhound-cli install && \
sleep 10 && \
docker exec bloodhound-app-db-1 psql -U bloodhound -d bloodhound -c "UPDATE feature_flags SET enabled = true WHERE key = 'opengraph_extension_management';" && \
# Uncomment/execute to show container logs
#docker logs -f bloodhound-bloodhound-1