# Generate recent.json and tags.json
# This script scans markdown files, extracts metadata, and generates JSON files
# for recent updates and tags

param(
    [string]$WorkspacePath = (Get-Location).Path
)

# Create assets/data directory if it doesn't exist
$dataDir = Join-Path -Path $WorkspacePath -ChildPath "assets/data"
if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}

# Define paths for output files
$recentJsonPath = Join-Path -Path $dataDir -ChildPath "recent.json"
$tagsJsonPath = Join-Path -Path $dataDir -ChildPath "tags.json"

# Function to extract YAML front matter from markdown files
function Get-MarkdownFrontMatter {
    param (
        [string]$FilePath
    )
    
    $content = Get-Content -Path $FilePath -Raw
    
    if ($content -match "^---\s*\r?\n(.*?)\r?\n---\s*\r?\n") {
        $frontMatter = $Matches[1]
        $yaml = @{}
        
        $frontMatter -split "\r?\n" | ForEach-Object {
            if ($_ -match "^(.*?):\s*(.*)$") {
                $key = $Matches[1].Trim()
                $value = $Matches[2].Trim()
                
                if ($key -eq "tags" -and $value -match "\[(.*)\]") {
                    $yaml[$key] = $Matches[1] -split ",\s*" | ForEach-Object { $_.Trim("' `"") }
                }
                elseif ($key -eq "date" -and $value -match '\d{4}-\d{2}-\d{2}') {
                    $yaml[$key] = $value
                }
                else {
                    $yaml[$key] = $value -replace '^[''"]|[''"]$', ''
                }
            }
        }
        
        return $yaml
    }
    
    return @{}
}

# Find all markdown files in the workspace
$markdownFiles = Get-ChildItem -Path $WorkspacePath -Recurse -Include "*.md" -File | 
    Where-Object { $_.FullName -notmatch "\\(_site|_drafts|node_modules)\\" }

# Process files for recent updates
$recentUpdates = @()
$tags = @{}

foreach ($file in $markdownFiles) {
    $relativePath = $file.FullName.Replace($WorkspacePath, "").TrimStart("\").Replace("\", "/")
    
    # Skip index.md and README.md files
    if ($file.Name -eq "index.md" -or $file.Name -eq "README.md") {
        continue
    }
    
    $frontMatter = Get-MarkdownFrontMatter -FilePath $file.FullName
    $title = if ($frontMatter.ContainsKey("title")) { $frontMatter["title"] } else { $file.BaseName }
    
    # Extract date from front matter or use file's last write time
    $dateString = if ($frontMatter.ContainsKey("date")) {
        $frontMatter["date"]
    }
    else {
        $file.LastWriteTime.ToString("yyyy-MM-dd")
    }
    
    # Extract tags
    if ($frontMatter.ContainsKey("tags") -and $frontMatter["tags"] -is [array]) {
        $frontMatter["tags"] | ForEach-Object {
            $tag = $_.Trim()
            if (-not [string]::IsNullOrEmpty($tag)) {
                if (-not $tags.ContainsKey($tag)) {
                    $tags[$tag] = 1
                }
                else {
                    $tags[$tag] += 1
                }
            }
        }
    }
    
    # Add to recent updates
    $recentUpdates += @{
        title = $title
        url = "/$relativePath" -replace ".md$", ""
        date = $dateString
    }
}

# Sort recent updates by date (newest first)
$recentUpdates = $recentUpdates | Sort-Object -Property @{Expression={$_.date}; Descending=$true}

# Output to JSON files
$recentUpdates | ConvertTo-Json | Out-File -FilePath $recentJsonPath -Encoding UTF8
$tags | ConvertTo-Json | Out-File -FilePath $tagsJsonPath -Encoding UTF8

Write-Output "Generated $recentJsonPath with $($recentUpdates.Count) entries"
Write-Output "Generated $tagsJsonPath with $($tags.Count) tags"
