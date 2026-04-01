#!/bin/bash

# Prerequisites: Docker Engine for Linux
# Install using the convenience script:
#   curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
# Then add your user to the docker group (log out and back in after):
#   sudo usermod -aG docker $USER
# Full instructions: https://docs.docker.com/engine/install/
cd /tmp && \
wget https://github.com/SpecterOps/bloodhound-cli/releases/download/v0.2.0/bloodhound-cli-linux-amd64.tar.gz && \
tar xvzf bloodhound-cli-linux-amd64.tar.gz && \
./bloodhound-cli config set graph_driver pg && \
yes | ./bloodhound-cli check && \
sed -i '/^  graph-db:/,/^  bloodhound:/{ /^  bloodhound:/!d; }; /neo4j-data/d; /graph-db/{N;d;}' ~/.config/bloodhound/docker-compose.yml && \
yes n | ./bloodhound-cli install && \
sleep 10 && \
docker exec bloodhound-app-db-1 psql -U bloodhound -d bloodhound -c "UPDATE feature_flags SET enabled = true WHERE key = 'opengraph_extension_management';" && \
docker logs -f bloodhound-bloodhound-1