# Generate Search Index for the Knowledge Base
# This script scans all markdown files and creates a JSON search index for Lunr.js

param(
    [string]$WorkspacePath = (Get-Location).Path
)

# Create assets/data directory if it doesn't exist
$dataDir = Join-Path -Path $WorkspacePath -ChildPath "assets/data"
if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}

$searchIndexPath = Join-Path -Path $dataDir -ChildPath "search-index.json"

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

# Function to extract content from markdown files (removing front matter)
function Get-MarkdownContent {
    param (
        [string]$FilePath
    )
    
    $content = Get-Content -Path $FilePath -Raw
    
    if ($content -match "^---\s*\r?\n.*?\r?\n---\s*\r?\n(.*)$") {
        return $Matches[1]
    }
    
    return $content
}

# Find all markdown files in the workspace
$markdownFiles = Get-ChildItem -Path $WorkspacePath -Recurse -Include "*.md" -File | 
    Where-Object { $_.FullName -notmatch "\\(_site|_drafts|node_modules)\\" }

# Process files for search index
$documents = @()
$counter = 0

foreach ($file in $markdownFiles) {
    $relativePath = $file.FullName.Replace($WorkspacePath, "").TrimStart("\").Replace("\", "/")
    
    # Create URL from relative path
    $url = "/$relativePath" -replace ".md$", ""
    
    # Get front matter and content
    $frontMatter = Get-MarkdownFrontMatter -FilePath $file.FullName
    $content = Get-MarkdownContent -FilePath $file.FullName
    
    # Clean up content for indexing (remove HTML tags)
    $content = $content -replace '<[^>]+>', ' '
    $content = $content -replace '\s+', ' '
    
    $title = if ($frontMatter.ContainsKey("title")) { $frontMatter["title"] } else { $file.BaseName }
    
    # Extract date from front matter or use file's last write time
    $dateString = if ($frontMatter.ContainsKey("date")) {
        $frontMatter["date"]
    }
    else {
        $file.LastWriteTime.ToString("yyyy-MM-dd")
    }
    
    # Create document for search index
    $document = @{
        id = $counter.ToString()
        title = $title
        content = $content
        url = $url
        date = $dateString
    }
    
    # Add tags if available
    if ($frontMatter.ContainsKey("tags") -and $frontMatter["tags"] -is [array]) {
        $document["tags"] = $frontMatter["tags"]
    }
    
    $documents += $document
    $counter++
}

# Create search index
$searchIndex = @{
    documents = $documents
}

# Output to JSON file
$searchIndex | ConvertTo-Json -Depth 5 | Out-File -FilePath $searchIndexPath -Encoding UTF8

Write-Output "Generated search index at $searchIndexPath with $($documents.Count) documents"
