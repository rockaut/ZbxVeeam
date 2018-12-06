
function Get-RepositoryData {
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
        $queryResult = Get-WmiObject -Namespace root/veeambs -Query "SELECT * FROM Repository"
        Write-Output ( $queryResult | Select-Object -Property InstanceUid, Name )
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
        $InstanceUid = "",
        $JobName = ""
    )
    Begin {
        if( $JobName -eq "" -and $InstanceUid -eq "" ) {
            Write-Output "Error: InstanceUid or JobName required!"
            break
        }

        if( $null -eq $JobName -and $null -eq $InstanceUid ) {
            Write-Output "Error: InstanceUid or JobName required!"
            break
        }
    }
    Process {
        if( $InstanceUid -eq "" -or $null -eq $InstanceUid ) {
            $queryResult = Get-WmiObject -Namespace root/veeambs -Query "SELECT * FROM Repository" | Where-Object { $_.Name -eq $JobName }
        }
        else {
            $queryResult = Get-WmiObject -Namespace ROOT/VeeamBS -Query ( "SELECT * FROM Repository WHERE InstanceUid='{0}'" -f $InstanceUid )
        }

        if( $null -eq $queryResult ) {
            $result = "Error: InstanceUid not found"
            Write-Output $result
            break
        }

        if( $queryResult -is [System.Array] ) {
            $result = "Error: InstanceUid is not unique"
            Write-Output $result
            break
        }

        #$result = $queryResult | Select-Object -Property * -ExcludeProperty "__*",Qualifiers,Site,Container,SystemProperties,Properties,ClassPath,Scope,Options

        $result = @{}
        $queryResult.Properties | Select-Object Name, Value | ForEach-Object {
            if( $_.Value.ToString().ToLower() -eq "true" ) { $result[($_.Name)] = 1 }
            elseif( $_.Value.ToString().ToLower() -eq "false" ) { $result[($_.Name)] = 0 }
            else { $result[($_.Name)] = $_.Value }
        }
        
        Write-Output ( $result | ConvertTo-Json -Depth 1 -Compress )

    } # end process
}
