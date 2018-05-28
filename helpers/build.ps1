$ScriptDir = Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent
$ModuleDir = Split-Path -Path $ScriptDir -Parent
$SrcDir = Join-Path -Path $ModuleDir -ChildPath "src"

$ModuleManifest = Join-Path -Path $SrcDir -ChildPath "ZbxVeeam.psd1"
 
Write-Host "Script directory: $ScriptDir"
Write-Host "Module directory: $ModuleDir"
Write-Host "Src directory   : $SrcDir"

##
##
##

function Update-ModuleVersion {
    $content = Get-Content -Path $ModuleManifest

    $newVersion = Get-Date -Format "yy.MM.dd.hhmmss"
    Write-Host "new version: $newVersion"

    $block = 'ModuleVersion     = \''.*\'''

    $replace = "ModuleVersion     = `'$newVersion`'"

    $content = $content -replace $block, $replace
    Set-Content -Path $ModuleManifest -Value $content
}

##
##
##

Update-ModuleVersion
