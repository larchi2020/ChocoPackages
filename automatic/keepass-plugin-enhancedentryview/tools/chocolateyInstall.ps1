﻿$ErrorActionPreference = 'Stop'

$packageArgs = @{
    packageName   = $env:ChocolateyPackageName
    url           = 'https://sourceforge.net/projects/kpenhentryview/files/v2.1.4/KPEnhancedEntryView-v2.1.4.zip/download'
    checksum      = '6a06e33a6c1494466a91715b9b69a7c732b68f73d3906e0674efaae99ce326e0'
    checksumType  = 'sha256'
}

$packageSearch = 'KeePass Password Safe*'
$installPath = ''

Write-Verbose "Searching for Keepass install location."
if ([array]$key = Get-UninstallRegistryKey -SoftwareName $packageSearch) {
    $installPath = $key.InstallLocation
}

if ([string]::IsNullOrEmpty($installPath)) {
    Write-Verbose "Cannot find '$packageSearch' in Add / Remove Programs or Programs and Features."
    Write-Verbose "Searching '$env:ChocolateyToolsLocation' for portable install..."
    $portPath = Join-Path -Path $env:ChocolateyToolsLocation -ChildPath "keepass"
    $installPath = Get-ChildItem -Directory "$portPath*" -ErrorAction SilentlyContinue

    if ([string]::IsNullOrEmpty($installPath)) {
        Write-Verbose "Searching '$env:Path' for unregistered install..."
        $installFullName = Get-Command -Name keepass -ErrorAction SilentlyContinue
        if ($installFullName) {
            $installPath = Split-Path $installFullName.Path -Parent
        }
    }
}

if ([string]::IsNullOrEmpty($installPath)) {
    # if we get here we haven't found Keepass
    throw "Cannot find Keepass! Exiting now as it's needed to install the plugin."
}


Write-Verbose "Found Keepass install location at '$installPath'."
$packageArgs.unzipLocation = Join-Path -Path $installPath -ChildPath 'Plugins'

Install-ChocolateyZipPackage @packageArgs

if (Get-Process -Name 'KeePass' -ErrorAction SilentlyContinue) {
    Write-Warning "Keepass is currently running. '$($packageArgs.packageName)' will be available at next restart."
}
else {
    Write-Host "'$($packageArgs.packageName)' will be loaded the next time KeePass is started."
}
