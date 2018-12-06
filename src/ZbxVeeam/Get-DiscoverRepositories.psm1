function Get-DiscoverRepositories {
    <#
	.SYNOPSIS
	.DESCRIPTION
	.PARAMETER Types
	.EXAMPLE
	#>
    param(

    )
    Begin {
        
    }
    Process {

        $data = @()

        $localReps = Get-VBRBackupRepository
        $localReps | ForEach-Object {
            $data += @{
                "{#REPID}"   = $_.Id
                "{#REPNAME}" = $_.Name
                "{#REPTYPE}" = $_.Type.ToString()
            }
        }

        $soReps = Get-VBRBackupRepository -ScaleOut
        $soReps | ForEach-Object {
            $data += @{
                "{#REPID}"   = $_.Id
                "{#REPNAME}" = $_.Name
                "{#REPTYPE}" = "ScaleOut"
            }

            $_.Extent | ForEach-Object {
                $data += @{
                    "{#REPID}"   = $_.Repository.Id
                    "{#REPNAME}" = $_.Name
                    "{#REPTYPE}" = "Extent"
                }
            }
        }

        $json = @{ "data" = $data }
        $json = $json | ConvertTo-Json -Compress
        Write-Output $json

    }
}
