# Prerequisites: Docker Desktop for Windows
# Download and install from: https://docs.docker.com/desktop/setup/install/windows-install/
# After installation, ensure Docker Desktop is running before executing this script.

$tempDir = $env:TEMP
$zipFile = Join-Path $tempDir "bloodhound-cli-windows-amd64.zip"
$extractDir = Join-Path $tempDir "bloodhound-cli"

Invoke-WebRequest -Uri "https://github.com/SpecterOps/bloodhound-cli/releases/download/v0.2.0/bloodhound-cli-windows-amd64.zip" -OutFile $zipFile
Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force

$cli = Join-Path $extractDir "bloodhound-cli.exe"
& $cli config set graph_driver pg

Read-Host "You may be prompted to overwrite YAML files. Answer Y to both this time. Press Enter to continue"
& $cli check

$composePath = Join-Path $env:LOCALAPPDATA "bloodhound\docker-compose.yml"
$content = Get-Content $composePath -Raw
# Remove the entire graph-db service block
$content = $content -replace '(?ms)^  graph-db:\r?\n.*?(?=^  bloodhound:)', ''
# Remove graph-db dependency and its condition line under depends_on
$content = $content -replace '(?m)^\s+graph-db:\r?\n\s+condition:.*\r?\n', ''
# Remove neo4j-data volume references
$content = $content -replace '(?m)^\s*neo4j-data.*\r?\n', ''
Set-Content -Path $composePath -Value $content -NoNewline

Read-Host "You will be prompted to overwrite YAML files. Answer N to both this time. Press Enter to continue"
& $cli install

Start-Sleep -Seconds 10

docker exec bloodhound-app-db-1 psql -U bloodhound -d bloodhound -c "UPDATE feature_flags SET enabled = true WHERE key = 'opengraph_extension_management';"

# Uncomment/execute to show container logs
#docker logs -f bloodhound-bloodhound-1
