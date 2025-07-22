# Agent OS Setup Script for Windows
# This script installs Agent OS files to your system

param(
    [switch]$OverwriteInstructions,
    [switch]$OverwriteStandards,
    [switch]$Help
)

# Show help if requested
if ($Help) {
    Write-Host "Usage: .\setup.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -OverwriteInstructions    Overwrite existing instruction files"
    Write-Host "  -OverwriteStandards       Overwrite existing standards files"
    Write-Host "  -Help                     Show this help message"
    Write-Host ""
    exit 0
}

Write-Host "🚀 Agent OS Setup Script (Windows)" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

# Base URL for raw GitHub content
# Allow BASE_URL override for testing purposes
# Usage: $env:BASE_URL = "http://localhost:8080"; .\setup.ps1
if ($env:BASE_URL) {
    $BASE_URL = $env:BASE_URL
    Write-Host "Using custom BASE_URL: $BASE_URL" -ForegroundColor Yellow
} else {
    $BASE_URL = "https://raw.githubusercontent.com/instrumental-products/agent-os/main"
}

# Create directories
Write-Host "📁 Creating directories..." -ForegroundColor Blue
$AgentOSPath = Join-Path $env:USERPROFILE ".agent-os"
$StandardsPath = Join-Path $AgentOSPath "standards"
$InstructionsPath = Join-Path $AgentOSPath "instructions"

New-Item -ItemType Directory -Force -Path $StandardsPath | Out-Null
New-Item -ItemType Directory -Force -Path $InstructionsPath | Out-Null

# Function to download file with overwrite logic
function Download-File {
    param(
        [string]$Url,
        [string]$Path,
        [string]$Description,
        [bool]$ShouldOverwrite
    )
    
    if ((Test-Path $Path) -and (-not $ShouldOverwrite)) {
        Write-Host "  ⚠️  $Description already exists - skipping" -ForegroundColor Yellow
        return
    }
    
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Path -UseBasicParsing
        if ($ShouldOverwrite -and (Test-Path $Path)) {
            Write-Host "  ✓ $Description (overwritten)" -ForegroundColor Green
        } else {
            Write-Host "  ✓ $Description" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  ❌ Failed to download $Description" -ForegroundColor Red
        Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Download standards files
Write-Host ""
Write-Host "📥 Downloading standards files to ~/.agent-os/standards/" -ForegroundColor Blue

$StandardsFiles = @(
    @{ Name = "tech-stack.md"; Description = "~/.agent-os/standards/tech-stack.md" },
    @{ Name = "code-style.md"; Description = "~/.agent-os/standards/code-style.md" },
    @{ Name = "best-practices.md"; Description = "~/.agent-os/standards/best-practices.md" }
)

foreach ($File in $StandardsFiles) {
    $Url = "$BASE_URL/standards/$($File.Name)"
    $Path = Join-Path $StandardsPath $File.Name
    Download-File -Url $Url -Path $Path -Description $File.Description -ShouldOverwrite $OverwriteStandards
}

# Download instruction files
Write-Host ""
Write-Host "📥 Downloading instruction files to ~/.agent-os/instructions/" -ForegroundColor Blue

$InstructionFiles = @(
    @{ Name = "plan-product.md"; Description = "~/.agent-os/instructions/plan-product.md" },
    @{ Name = "create-spec.md"; Description = "~/.agent-os/instructions/create-spec.md" },
    @{ Name = "execute-tasks.md"; Description = "~/.agent-os/instructions/execute-tasks.md" },
    @{ Name = "analyze-product.md"; Description = "~/.agent-os/instructions/analyze-product.md" }
)

foreach ($File in $InstructionFiles) {
    $Url = "$BASE_URL/instructions/$($File.Name)"
    $Path = Join-Path $InstructionsPath $File.Name
    Download-File -Url $Url -Path $Path -Description $File.Description -ShouldOverwrite $OverwriteInstructions
}

Write-Host ""
Write-Host "✅ Agent OS base installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Files installed to:" -ForegroundColor Cyan
Write-Host "   ~/.agent-os/standards/     - Your development standards"
Write-Host "   ~/.agent-os/instructions/  - Agent OS instructions"
Write-Host ""

if (-not $OverwriteInstructions -and -not $OverwriteStandards) {
    Write-Host "💡 Note: Existing files were skipped to preserve your customizations" -ForegroundColor Yellow
    Write-Host "   Use -OverwriteInstructions or -OverwriteStandards to update specific files"
} else {
    Write-Host "💡 Note: Some files were overwritten based on your flags" -ForegroundColor Yellow
    if (-not $OverwriteInstructions) {
        Write-Host "   Existing instruction files were preserved"
    }
    if (-not $OverwriteStandards) {
        Write-Host "   Existing standards files were preserved"
    }
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Customize your coding standards in ~/.agent-os/standards/"
Write-Host ""
Write-Host "2. Install commands for your AI coding assistant(s):"
Write-Host ""
Write-Host "   - Using Claude Code? Install the Claude Code commands with:"
Write-Host "     PowerShell: .\setup-claude-code.ps1" -ForegroundColor Yellow
Write-Host "     Bash/WSL: curl -sSL https://raw.githubusercontent.com/instrumental-products/agent-os/main/setup-claude-code.sh | bash"
Write-Host ""
Write-Host "   - Using Cursor? Install the Cursor commands with:"
Write-Host "     PowerShell: .\setup-cursor.ps1" -ForegroundColor Yellow
Write-Host "     Bash/WSL: curl -sSL https://raw.githubusercontent.com/instrumental-products/agent-os/main/setup-cursor.sh | bash"
Write-Host ""
Write-Host "   - Using something else? See instructions at https://buildermethods.com/agent-os"
Write-Host ""
Write-Host "Learn more at https://buildermethods.com/agent-os" -ForegroundColor Cyan
Write-Host ""