#!/usr/bin/env pwsh
[CmdletBinding()]
param($Org = "SpecterOps")
$OutputFile = "lab2_1_$Org-opengraph.json"

# Fetch org details
$orgUrl = "https://api.github.com/orgs/$Org"
Write-Verbose "GET $orgUrl"
$orgInfo = Invoke-RestMethod -Uri $orgUrl

# Fetch up to 5 public repos for the org
$apiUrl = "https://api.github.com/orgs/$Org/repos?per_page=5"
Write-Verbose "GET $apiUrl"
$repos = Invoke-RestMethod -Uri $apiUrl
Write-Verbose ($repos | ConvertTo-Json -Depth 5)

# Start with the organization node
$orgProps = @{}
$orgInfo.PSObject.Properties | Where-Object { $null -ne $_.Value -and $_.Value -isnot [System.Management.Automation.PSObject] -and $_.Value -isnot [System.Array] } | ForEach-Object { $orgProps[$_.Name] = $_.Value }
$nodes = @(@{ id = "GH:$Org"; kinds = @("GH_Organization"); properties = $orgProps })
$edges = @()
$seenUsers = @{}

foreach ($repo in $repos) {
    $repoFull = $repo.full_name

    # Add repo node — only keep scalar properties (strings, numbers, bools)
    $repoProps = @{}
    $repo.PSObject.Properties | Where-Object { $null -ne $_.Value -and $_.Value -isnot [System.Management.Automation.PSObject] -and $_.Value -isnot [System.Array] } | ForEach-Object { $repoProps[$_.Name] = $_.Value }
    $nodes += @{ id = "GH:$repoFull"; kinds = @("GH_Repo"); properties = $repoProps }
    $edges += @{
        start = @{ match_by = "id"; value = "GH:$Org" }
        end   = @{ match_by = "id"; value = "GH:$repoFull" }
        kind  = "GH_Contains"
    }

    # Fetch contributors for this repo
    $contribUrl = "https://api.github.com/repos/$repoFull/contributors?per_page=100"
    Write-Verbose "GET $contribUrl"
    try {
        $contributors = Invoke-RestMethod -Uri $contribUrl
    } catch {
        Write-Warning "Could not fetch contributors for $repoFull"
        continue
    }

    foreach ($contributor in $contributors) {
        # Only add each user node once
        if (-not $seenUsers.ContainsKey($contributor.login)) {
            $props = @{}
            $contributor.PSObject.Properties | Where-Object { $null -ne $_.Value -and $_.Value -isnot [System.Management.Automation.PSObject] -and $_.Value -isnot [System.Array] } | ForEach-Object { $props[$_.Name] = $_.Value }
            $props["name"] = $contributor.login
            $nodes += @{ id = "GH:$($contributor.login)"; kinds = @("GH_User"); properties = $props }
            $seenUsers[$contributor.login] = $true
        }

        $edges += @{
            start = @{ match_by = "id"; value = "GH:$($contributor.login)" }
            end   = @{ match_by = "id"; value = "GH:$repoFull" }
            kind  = "GH_ContributedTo"
        }
    }
}

# Wrap in the BloodHound payload format and save to disk
@{ metadata = @{ source_kind = "GH" }; graph = @{ nodes = $nodes; edges = $edges } } | ConvertTo-Json -Depth 10 | Set-Content $OutputFile -Encoding utf8

Write-Host "Done! Wrote $($nodes.Count) nodes and $($edges.Count) edges to: $OutputFile"
