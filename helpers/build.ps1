param(
    [switch]$NoBuild,
    [switch]$PublishPowershellGallery,
    [string]$PowershellGalleryAPIKey = ""
)

$ScriptDir = Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent
$ModuleDir = Split-Path -Path $ScriptDir -Parent
$SrcDir = Join-Path -Path $ModuleDir -ChildPath "src\ZbxVeeam"

$ModuleManifest = Join-Path -Path $SrcDir -ChildPath "ZbxVeeam.psd1"

$ModulePath = "C:\Program Files\WindowsPowerShell\Modules"
 
Write-Host "Script directory: $ScriptDir"
Write-Host "Module directory: $ModuleDir"
Write-Host "Src directory   : $SrcDir"

Write-Host "User Module Path: $ModulePath"

##
##
##

function Deploy-Module {

    Copy-Item -Path $SrcDir -Destination $ModulePath -Recurse -Force
}

function Update-ModuleVersion {
    $content = Get-Content -Path $ModuleManifest

    $newVersion = Get-Date -Format "yy.MM.dd.HHmmss"
    Write-Host "new version: $newVersion"

    $block = 'ModuleVersion.*= \''.*\'''

    $replace = "ModuleVersion     = `'$newVersion`'"

    $content = $content -replace $block, $replace

    Set-Content -Path $ModuleManifest -Value $content
}

##
##
##

if ( $NoBuild -eq $false ) {
    Update-ModuleVersion
}

Deploy-Module
Import-Module ZbxVeeam -Force
Get-Module | Format-List

if ( $PublishPowershellGallery ) {
    if ( $PowershellGalleryAPIKey -ne "" ) {
        Publish-Module -Name ZbxVeeam -NuGetApiKey $PowershellGalleryAPIKey -Verbose
    }
}
