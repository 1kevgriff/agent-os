# Agent OS Claude Code Setup Script for Windows
# This script installs Agent OS commands for Claude Code

param(
    [switch]$Help
)

# Show help if requested
if ($Help) {
    Write-Host "Usage: .\setup-claude-code.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help    Show this help message"
    Write-Host ""
    exit 0
}

Write-Host "🚀 Agent OS Claude Code Setup (Windows)" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
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

# Base URL for raw GitHub content
$BASE_URL = "https://raw.githubusercontent.com/instrumental-products/agent-os/main"

# Create directories
Write-Host "📁 Creating directories..." -ForegroundColor Blue
$ClaudeCommandsPath = Join-Path $env:USERPROFILE ".claude\commands"
$ClaudePath = Join-Path $env:USERPROFILE ".claude"

New-Item -ItemType Directory -Force -Path $ClaudeCommandsPath | Out-Null

# Function to download file with existence check
function Download-ClaudeFile {
    param(
        [string]$Url,
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path $Path) {
        Write-Host "  ⚠️  $Description already exists - skipping" -ForegroundColor Yellow
        return
    }
    
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Path -UseBasicParsing
        Write-Host "  ✓ $Description" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Failed to download $Description" -ForegroundColor Red
        Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Download command files for Claude Code
Write-Host ""
Write-Host "📥 Downloading Claude Code command files to ~/.claude/commands/" -ForegroundColor Blue

$CommandFiles = @("plan-product", "create-spec", "execute-tasks", "analyze-product")

foreach ($Cmd in $CommandFiles) {
    $Url = "$BASE_URL/commands/$Cmd.md"
    $Path = Join-Path $ClaudeCommandsPath "$Cmd.md"
    $Description = "~/.claude/commands/$Cmd.md"
    Download-ClaudeFile -Url $Url -Path $Path -Description $Description
}

# Download Claude Code user CLAUDE.md
Write-Host ""
Write-Host "📥 Downloading Claude Code configuration to ~/.claude/" -ForegroundColor Blue

$ClaudeMdPath = Join-Path $ClaudePath "CLAUDE.md"
$ClaudeMdDescription = "~/.claude/CLAUDE.md"

if (Test-Path $ClaudeMdPath) {
    Write-Host "  ⚠️  $ClaudeMdDescription already exists - skipping" -ForegroundColor Yellow
} else {
    try {
        $Url = "$BASE_URL/claude-code/user/CLAUDE.md"
        Invoke-WebRequest -Uri $Url -OutFile $ClaudeMdPath -UseBasicParsing
        Write-Host "  ✓ $ClaudeMdDescription" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Failed to download $ClaudeMdDescription" -ForegroundColor Red
        Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ Agent OS Claude Code installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Files installed to:" -ForegroundColor Cyan
Write-Host "   ~/.claude/commands/        - Claude Code commands"
Write-Host "   ~/.claude/CLAUDE.md        - Claude Code configuration"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Initiate Agent OS in a new product's codebase with:"
Write-Host "  /plan-product" -ForegroundColor Yellow
Write-Host ""
Write-Host "Initiate Agent OS in an existing product's codebase with:"
Write-Host "  /analyze-product" -ForegroundColor Yellow
Write-Host ""
Write-Host "Initiate a new feature with:"
Write-Host "  /create-spec (or simply ask 'what's next?')" -ForegroundColor Yellow
Write-Host ""
Write-Host "Build and ship code with:"
Write-Host "  /execute-task" -ForegroundColor Yellow
Write-Host ""
Write-Host "Learn more at https://buildermethods.com/agent-os" -ForegroundColor Cyan
Write-Host ""