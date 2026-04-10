#!/usr/bin/env pwsh
[CmdletBinding()]
param($Repo = "SpecterOps/BloodHound")
$OutputFile = "lab2_0_$($Repo -replace '/', '-')-opengraph.json"
$apiUrl = "https://api.github.com/repos/$Repo/contributors?per_page=100"
Write-Verbose "GET $apiUrl"
$contributors = Invoke-RestMethod -Uri $apiUrl
Write-Verbose ($contributors | ConvertTo-Json -Depth 5)

# Start the graph with the repo node
$nodes = @( @{ id = "GH:$Repo"; kinds = @("GH_Repo"); properties = @{ name = $Repo } } )
$edges = @()

# If the repo contains an org (e.g. "SpecterOps/BloodHound"), add the org node and a GH_Contains edge
if ($Repo -match '/') {
    $Org = $Repo.Split('/')[0]
    $orgInfo = Invoke-RestMethod -Uri "https://api.github.com/orgs/$Org"
    $orgProps = @{}
    $orgInfo.PSObject.Properties | Where-Object { $null -ne $_.Value -and $_.Value -isnot [System.Management.Automation.PSObject] -and $_.Value -isnot [System.Array] } | ForEach-Object { $orgProps[$_.Name] = $_.Value }
    $nodes = @(@{ id = "GH:$Org"; kinds = @("GH_Organization"); properties = $orgProps }) + $nodes
    $edges += @{
        start = @{ match_by = "id"; value = "GH:$Org" }
        end   = @{ match_by = "id"; value = "GH:$Repo" }
        kind  = "GH_Contains"
    }
}

# Add each contributor as a node, and draw an edge from them to the repo
foreach ($contributor in $contributors) {

    # Convert every field from the API response into node properties
    $props = @{}
    $contributor.PSObject.Properties | ForEach-Object { $props[$_.Name] = $_.Value }
    $props["name"] = $contributor.login

    $nodes += @{ id = "GH:$($contributor.login)"; kinds = @("GH_User"); properties = $props }
    $edges += @{
        start = @{ match_by = "id"; value = "GH:$($contributor.login)" }
        end   = @{ match_by = "id"; value = "GH:$Repo" }
        kind  = "GH_ContributedTo"
    }
}

# Wrap in the BloodHound payload format and save to disk
@{ metadata = @{ source_kind = "GH" }; graph = @{ nodes = $nodes; edges = $edges } } | ConvertTo-Json -Depth 10 | Set-Content $OutputFile -Encoding utf8

Write-Host "Done! Wrote $($nodes.Count) nodes and $($edges.Count) edges to: $OutputFile"