# Download and install .NET SDK versions
param(
    [string]$InstallPath = ".dotnet"
)

# Create installation directory if it doesn't exist
if (!(Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Write-Host "Created directory: $InstallPath"
}

# Download the dotnet-install.ps1 script
$DotNetInstallerUri = "https://dot.net/v1/dotnet-install.ps1"
$ScriptPath = Join-Path $InstallPath 'dotnet-install.ps1'

Write-Host "Downloading dotnet-install.ps1..."
try {
    (New-Object System.Net.WebClient).DownloadFile($DotNetInstallerUri, $ScriptPath)
    Write-Host "Downloaded dotnet-install.ps1 to: $ScriptPath"
} catch {
    Write-Error "Failed to download dotnet-install.ps1: $_"
    exit 1
}

# Function to remove PATH variable entries
function Remove-PathVariable([string]$VariableToRemove) {
    $SplitChar = ';'
    if ($IsMacOS -or $IsLinux) {
        $SplitChar = ':'
    }

    $path = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($path -ne $null) {
        $newItems = $path.Split($SplitChar, [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { "$($_)" -inotlike $VariableToRemove }
        [Environment]::SetEnvironmentVariable("PATH", [System.String]::Join($SplitChar, $newItems), "User")
    }

    $path = [Environment]::GetEnvironmentVariable("PATH", "Process")
    if ($path -ne $null) {
        $newItems = $path.Split($SplitChar, [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { "$($_)" -inotlike $VariableToRemove }
        [Environment]::SetEnvironmentVariable("PATH", [System.String]::Join($SplitChar, $newItems), "Process")
    }
}

# Install .NET SDK 8.0.x (latest)
Write-Host "Installing .NET SDK 8.0.x..."
try {
    & $ScriptPath -Channel "8.0" -Version "latest" -InstallDir $InstallPath
    Write-Host "Successfully installed .NET SDK 8.0.x"
} catch {
    Write-Error "Failed to install .NET SDK 8.0.x: $_"
}

# Install .NET SDK 10.0.100-preview.6.25358.103
Write-Host "Installing .NET SDK 10.0.100-preview.6.25358.103..."
try {
    & $ScriptPath -Version "10.0.100-preview.6.25358.103" -InstallDir $InstallPath
    Write-Host "Successfully installed .NET SDK 10.0.100-preview.6.25358.103"
} catch {
    Write-Error "Failed to install .NET SDK 10.0.100-preview.6.25358.103: $_"
}

# Update PATH for current session
Remove-PathVariable "$InstallPath"
$env:PATH = "$InstallPath;$env:PATH"

Write-Host "Installation complete!"
Write-Host "Installed .NET SDKs in: $InstallPath"
Write-Host "Updated PATH for current session to include: $InstallPath"

# Verify installations
Write-Host "`nVerifying installations..."
try {
    $dotnetPath = Join-Path $InstallPath "dotnet.exe"
    if (Test-Path $dotnetPath) {
        & $dotnetPath --list-sdks
    } else {
        Write-Warning "dotnet.exe not found in $InstallPath"
    }
} catch {
    Write-Warning "Could not verify installations: $_"
}


dotnet new sln --help -d -v diag
dotnet new sln -v diag -d --format slnx