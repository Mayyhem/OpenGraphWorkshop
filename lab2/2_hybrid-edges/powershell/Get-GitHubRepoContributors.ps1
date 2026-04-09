#!/usr/bin/env pwsh
[CmdletBinding()]
param($Repo = "SpecterOps/BloodHound")
$OutputFile = "lab2_2_$($Repo -replace '/', '-')-opengraph.json"
$apiUrl = "https://api.github.com/repos/$Repo/contributors?per_page=100"
Write-Verbose "GET $apiUrl"
$contributors = Invoke-RestMethod -Uri $apiUrl
Write-Verbose ($contributors | ConvertTo-Json -Depth 5)

# Start the graph with the repo as the only node
$nodes = @( @{ id = "GH:$Repo"; kinds = @("GH_Repo"); properties = @{ name = $Repo } } )
$edges = @()

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
    # Check if the user has an X (Twitter) handle on their GitHub profile
    $userInfo = Invoke-RestMethod -Uri "https://api.github.com/users/$($contributor.login)"
    $twitter = $userInfo.twitter_username
    if ($twitter) {
        $xId = "x:$twitter"
        $xUrl = "https://x.com/$twitter"
        $nodes += @{ id = $xId; kinds = @("X_User"); properties = @{ login = $twitter; name = $twitter; url = $xUrl } }
        $edges += @{
            start = @{ match_by = "id"; value = "GH:$($contributor.login)" }
            end   = @{ match_by = "id"; value = $xId }
            kind  = "GH_MatchesUser"
        }
        Write-Host "  [+] X match: $($contributor.login) -> @$twitter"
    } else {
        Write-Host "  [-] No X handle: $($contributor.login)"
    }
}

# Wrap in the BloodHound payload format and save to disk
@{ metadata = @{ source_kind = "GH" }; graph = @{ nodes = $nodes; edges = $edges } } | ConvertTo-Json -Depth 10 | Set-Content $OutputFile -Encoding utf8

Write-Host "Done! Wrote $($nodes.Count) nodes and $($edges.Count) edges to: $OutputFile"
