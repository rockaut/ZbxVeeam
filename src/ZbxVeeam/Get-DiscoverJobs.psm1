function Get-DiscoverJobs {
    <#
	.SYNOPSIS
	.DESCRIPTION
	.PARAMETER Types
	.EXAMPLE
	#>
    param(
        $Types = '*'
    )
    Begin {
        if ( $Types -eq 'all' -or $Types -eq '*' -or $Types -eq $null ) {
            $Types = @( 'backup', 'backuptotape' )
        }
    }
    Process {

        $data = @()
        
        $Types | ForEach-Object {

            switch ( $_ ) {
                'backup' {
                    $jobs = Get-VBRJob
                    $jobs | ForEach-Object {
                        $data += @{
                            "{#JOBID}"   = $_.Id
                            "{#JOBNAME}" = $_.Name
                            "{#JOBTYPE}" = $_.JobType.ToString()
                        }
                    }
                }
                'backuptotape' {
                    $jobs = Get-VBRTapeJob
                    $jobs | ForEach-Object {
                        $data += @{
                            "{#JOBID}"   = $_.Id
                            "{#JOBNAME}" = $_.Name
                            "{#JOBTYPE}" = $_.Type.ToString()
                        }
                    }
                }
                default {
                    Write-Output 'Not Found'
                }
            }

        }

        $json = @{ "data" = $data }
        $json = $json | ConvertTo-Json -Compress
        Write-Output $json

    }
}
