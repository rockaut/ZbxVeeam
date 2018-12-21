function Get-DiscoverWmi {
    <#
	.SYNOPSIS
	.DESCRIPTION
	.PARAMETER Types
	.EXAMPLE
    #>
    param(
        $Query = "",
        $Properties = ""
    )
    Process {
        $queryResult = Get-WmiObject -Namespace root/veeambs -Query $Query
        $splitProps = $Properties.Split("|")
        
        $filteredResult = $queryResult | Select-Object -Property $splitProps
        
        $discoveryResult = @()
        $filteredResult | ForEach-Object {
            $fr = $_
            $o = @{}
            
            $splitProps | ForEach-Object {
                $cp = $_
                $oKey = "{" + ("#{0}" -f $cp.ToString().ToUpper()) + "}"
                $o[$oKey] = $fr.($cp)
            }
            $discoveryResult += $o
        }

        @{ "data" = $discoveryResult } | ConvertTo-Json -Compress
    }
}