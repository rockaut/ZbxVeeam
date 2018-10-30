
function Get-RepositoryData {
    <#
	.SYNOPSIS
	.DESCRIPTION
	.PARAMETER Types
	.EXAMPLE
	#>
    param(
        $Name = ""
    )
    Begin {
        $path = "C:\Windows\Temp\{0}.data.json" -f $Name
        if ( (Test-Path -Path $path) -eq $false ) {
            Write-Output "ERROR: File/Data not found!"
            exit 1
        }
    }
    Process {
        Get-Content -Path $path -Raw
    }
}

function Get-RepositoryDetails {
    <#
	.SYNOPSIS
	.DESCRIPTION
	.PARAMETER Types
	.EXAMPLE
	#>
    param(
        $Name = "all",
        $Type = "*",
        $Processing = 'cache'
    )
    Begin {
        $GetAll = ( $Name -eq "all" )

        if ( $Processing -notin @('out', 'send', 'raw', 'cache') ) {
            $Processing = 'cache'
        }

        $repos = @()
        $sorep = @()

        $result = "Ok [{0}]" -f $Processing
    }
    Process {

        if ( $GetAll ) {
            $repos = Get-VBRBackupRepository
            $sorep = Get-VBRBackupRepository -ScaleOut
        }
        else {
            if ( $Type -eq "ScaleOut" ) {
                $sorep = Get-VBRBackupRepository -ScaleOut -Name $Name
            }
            elseif ( $Type -eq "Extent" ) {
                $repos = ( Get-VBRBackupRepository -ScaleOut | Get-VBRRepositoryExtent | where { $_.Name -eq $Name } ).Repository
            }
        }

        $repos | ForEach-Object {
            $currentRep = $_

            $data = @{
                "Name" = $currentRep.Name
                "Id"   = $currentRep.Id
                "Info" = @{
                    "CachedTotalSpace[total]" = $currentRep.Info.CachedTotalSpace
                    "CachedFreeSpace[total]"  = $currentRep.Info.CachedFreeSpace
                }
            }

            $json = $data | ConvertTo-Json -Compress

            if ( $Processing -eq "send" ) {
                $json = $json.Replace('"', '\"')
                $s = $currentRep.Id
                #$result = & "C:\Program Files\zabbix_agent\bin\win64\zabbix_sender.exe" -c "C:\Program Files\zabbix_agent\conf\zabbix_agentd.win.conf" -s "$s" -k "repo-data" -v -o ("{0}" -f $json)
                
                '"{0}" "repo-data" "{1}"' -f $s, $json | Out-File -FilePath "C:\Windows\Temp\$s.send.json" -Encoding default
                $result = & "C:\Program Files\zabbix_agent\bin\win64\zabbix_sender.exe" -c "C:\Program Files\zabbix_agent\conf\zabbix_agentd.win.conf" -v -i "C:\Windows\Temp\$s.send.json"
                
                Write-Output ( "{0} ({1})" -f $currentRep.Name, $currentRep.Id)
                Write-Output $result
            }
            elseif ( $Processing -eq "out" ) {
                $json = $json.Replace('"', '\"')
                Write-Output $json
            }
            elseif ( $Processing -eq "raw" ) {
                Write-Output $json
            }
            else {
                $path = "C:\Windows\Temp\{0}.data.json" -f $currentRep.Id
                $json | Out-File -FilePath $path -Encoding utf8 -Force
            }
        }

        $sorep | ForEach-Object {
            $currentSorep = $_

            $data = @{
                "Name" = $currentSorep.Name
                "Id"   = $currentRep.Id
                "Info" = @{
                    "CachedTotalSpace" = 0
                    "CachedFreeSpace"  = 0
                }
            }

            $currentSorep.Extent.Repository | ForEach-Object {

                $currentRep = $_

                $data["Info"]["CachedTotalSpace[total]"] += $currentRep.Info.CachedTotalSpace
                $data["Info"]["CachedFreeSpace[total]"] += $currentRep.Info.CachedFreeSpace

            }

            $json = $data | ConvertTo-Json -Compress

            if ( $Processing -eq "send" ) {
                $json = $json.Replace('"', '\"')
                $s = $currentSorep.Id
                #$result = & "C:\Program Files\zabbix_agent\bin\win64\zabbix_sender.exe" -c "C:\Program Files\zabbix_agent\conf\zabbix_agentd.win.conf" -s "$s" -k "repo-data" -v -o ("{0}" -f $json)
                
                '"{0}" "repo-data" "{1}"' -f $s, $json | Out-File -FilePath "C:\Windows\Temp\$s.send.json" -Encoding default
                $result = & "C:\Program Files\zabbix_agent\bin\win64\zabbix_sender.exe" -c "C:\Program Files\zabbix_agent\conf\zabbix_agentd.win.conf" -v -i "C:\Windows\Temp\$s.send.json"
                
                Write-Output ( "{0} ({1})" -f $currentSorep.Name, $currentSorep.Id)
                Write-Output $result
            }
            elseif ( $Processing -eq "out" ) {
                $json = $json.Replace('"', '\"')
                Write-Output $json
            }
            elseif ( $Processing -eq "raw" ) {
                Write-Output $json
            }
            else {
                $path = "C:\Windows\Temp\{0}.data.json" -f $currentRep.Id
                $json | Out-File -FilePath $path -Encoding utf8 -Force
            }
        }
    } # end process
}
