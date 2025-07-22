# Agent OS Cursor Setup Script for Windows
# This script installs Agent OS commands for Cursor in the current project

param(
    [switch]$Help
)

# Show help if requested
if ($Help) {
    Write-Host "Usage: .\setup-cursor.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help    Show this help message"
    Write-Host ""
    exit 0
}

Write-Host "🚀 Agent OS Cursor Setup (Windows)" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

# Check if Agent OS base installation is present
$AgentOSInstructions = Join-Path $env:USERPROFILE ".agent-os\instructions"
$AgentOSStandards = Join-Path $env:USERPROFILE ".agent-os\standards"

if (-not (Test-Path $AgentOSInstructions) -or -not (Test-Path $AgentOSStandards)) {
    Write-Host "⚠️  Agent OS base installation not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please install the Agent OS base installation first:"
    Write-Host ""
    Write-Host "Option 1 - PowerShell (recommended for Windows):"
    Write-Host "  .\setup.ps1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 2 - Bash/WSL:"
    Write-Host "  curl -sSL https://raw.githubusercontent.com/instrumental-products/agent-os/main/setup.sh | bash"
    Write-Host ""
    Write-Host "Option 3 - Manual installation:"
    Write-Host "  Follow instructions at https://buildermethods.com/agent-os"
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "📁 Creating .cursor/rules directory..." -ForegroundColor Blue
$CursorRulesPath = ".cursor\rules"
New-Item -ItemType Directory -Force -Path $CursorRulesPath | Out-Null

# Base URL for raw GitHub content
# Allow BASE_URL override for testing purposes
# Usage: $env:BASE_URL = "http://localhost:8080"; .\setup-cursor.ps1
if ($env:BASE_URL) {
    $BASE_URL = $env:BASE_URL
    Write-Host "Using custom BASE_URL: $BASE_URL" -ForegroundColor Yellow
} else {
    $BASE_URL = "https://raw.githubusercontent.com/instrumental-products/agent-os/main"
}

Write-Host ""
Write-Host "📥 Downloading and setting up Cursor command files..." -ForegroundColor Blue

# Function to process a command file
function Process-CommandFile {
    param(
        [string]$CommandName
    )
    
    $TempFile = Join-Path $env:TEMP "$CommandName.md"
    $TargetFile = Join-Path $CursorRulesPath "$CommandName.mdc"
    
    try {
        # Download the file
        $Url = "$BASE_URL/commands/$CommandName.md"
        Invoke-WebRequest -Uri $Url -OutFile $TempFile -UseBasicParsing
        
        # Create the front-matter and append original content
        $FrontMatter = @"
---
alwaysApply: false
---

"@
        
        # Read the original content
        $OriginalContent = Get-Content $TempFile -Raw
        
        # Write the target file with front-matter and content
        $FrontMatter + $OriginalContent | Set-Content $TargetFile -Encoding UTF8
        
        # Clean up temp file
        Remove-Item $TempFile -Force -ErrorAction SilentlyContinue
        
        Write-Host "  ✓ .cursor/rules/$CommandName.mdc" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Failed to download $CommandName.md" -ForegroundColor Red
        Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Red
        
        # Clean up temp file on error
        Remove-Item $TempFile -Force -ErrorAction SilentlyContinue
        return $false
    }
    
    return $true
}

# Process each command file
$CommandFiles = @("plan-product", "create-spec", "execute-tasks", "analyze-product")

foreach ($Cmd in $CommandFiles) {
    Process-CommandFile -CommandName $Cmd | Out-Null
}

Write-Host ""
Write-Host "✅ Agent OS Cursor setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Files installed to:" -ForegroundColor Cyan
Write-Host "   .cursor/rules/             - Cursor command rules"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Use Agent OS commands in Cursor with @ prefix:"
Write-Host "  @plan-product    - Initiate Agent OS in a new product's codebase" -ForegroundColor Yellow
Write-Host "  @analyze-product - Initiate Agent OS in an existing product's codebase" -ForegroundColor Yellow
Write-Host "  @create-spec     - Initiate a new feature (or simply ask 'what's next?')" -ForegroundColor Yellow
Write-Host "  @execute-tasks    - Build and ship code" -ForegroundColor Yellow
Write-Host ""
Write-Host "Learn more at https://buildermethods.com/agent-os" -ForegroundColor Cyan
Write-Host ""