function Set-Defaults {
    param(
        $Server = 'localhost',
        $Port = 9392,
        $Timeout = 5
    )
    Process {
        $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Server'] = $Server
        $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Port'] = $Port
        $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Timeout'] = $Timeout
    }
}

function Get-Defaults {
    Process {
        Write-Output ( "Server : {0}" -f $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Server'] )
        Write-Output ( "Port   : {0}" -f $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Port'] )
        Write-Output ( "Timeout: {0}" -f $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Timeout'] )
    }
}

function Get-Wrapper {
    process {

        $args = $args[0]

        #$args.Length
        #"--"
        #$args
        #"--"
        #"Arg1 - " + $args[0]
        #"Arg2 - " + $args[1]
        #"Arg3 - " + $args[2]
        #"Arg4 - " + $args[3]
        #"Arg5 - " + $args[4]
        #"Arg6 - " + $args[5]
        #"server - " + $args[6]
        #"port - " + $args[7]
        #"timeout - " + $args[8]
        #"--"

        if ( $args[0] -eq "" -or $args[0] -eq $null ) { $arg1 = $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Arg1'] } else { $arg1 = $args[0] }
        if ( $args[1] -eq "" -or $args[1] -eq $null ) { $arg2 = $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Arg2'] } else { $arg2 = $args[1] }
        if ( $args[2] -eq "" -or $args[2] -eq $null ) { $arg3 = $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Arg3'] } else { $arg3 = $args[2] }
        if ( $args[3] -eq "" -or $args[3] -eq $null ) { $arg4 = $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Arg4'] } else { $arg4 = $args[3] }
        if ( $args[4] -eq "" -or $args[4] -eq $null ) { $arg5 = $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Arg5'] } else { $arg5 = $args[4] }
        if ( $args[5] -eq "" -or $args[5] -eq $null ) { $arg6 = $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Arg6'] } else { $arg6 = $args[5] }
        if ( $args[6] -eq "" -or $args[6] -eq $null ) { $server = $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Server'] } else { $server = $args[6] }
        if ( $args[7] -eq "" -or $args[7] -eq $null ) { $port = $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Port'] } else { $port = $args[7] }
        if ( $args[8] -eq "" -or $args[8] -eq $null ) { $timeout = $MyInvocation.MyCommand.Module.PrivateData['Defaults']['Timeout'] } else { $timeout = $args[8] }

        #"--"
        #"Arg1 - " + $arg1
        #"Arg2 - " + $arg2
        #"Arg3 - " + $arg3
        #"Arg4 - " + $arg4
        #"Arg5 - " + $arg5
        #"Arg6 - " + $arg6
        #"server - " + $server
        #"port - " + $port
        #"timeout - " + $timeout
        #exit

        Connect-VBRServer -Server $server -Port $port -Timeout $timeout

        switch ( $arg1.ToString().ToLower() ) {
            "discover" {
                switch ( $arg2.ToString().ToLower() ) {
                    'jobs' {
                        Get-DiscoverJobs -Type $arg3
                    }
                    'repositories' {
                        Get-DiscoverRepositories
                    }
                    Default {}
                }
            }
            "job" {
                switch ( $arg2.ToString().ToLower() ) {
                    'details' {
                        Get-JobDetails -Job $arg3 -Processing $arg4 -NameMatch $arg5 -TypeMatch $arg6
                    }
                    Default {}
                }
            }
            "repository" {
                switch ( $arg2.ToString().ToLower() ) {
                    'details' {
                        Get-RepositoryDetails -Name $arg3 -Processing $arg4
                    }
                    'data' {
                        Get-RepositoryData -Name $arg3
                    }
                    Default {}
                }
            }
            Default {  }
        }
    }
    End {
        Disconnect-VBRServer
    }
}

function Convert-DateString ([String]$Date, [String[]]$Format) {
    $result = New-Object DateTime
 
    $convertible = [DateTime]::TryParseExact(
        $Date,
        $Format,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::None,
        [ref]$result)
 
    if ($convertible) { $result }
}

function Install-ForAgent {
    param(
        $ZbxVeeamConfFile = "C:\Program Files\zabbix_agent\conf\zbx_veeam.conf",
        $ZabbixConfFile = "C:\Program Files\zabbix_agent\conf\zabbix_agentd.win.conf",
        [switch]$AddInclude,
        [switch]$NoRestartAgent
    )
    Process {
        $content = @(
            'UserParameter=zbxveeam[*], powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { Add-PSSnapin VeeamPsSnapin; Import-Module ZbxVeeam -Force; Get-ZbxVeeamWrapper $args }" ''$1'' ''$2'' ''$3'' ''$4'' ''$5'' ''$6'' ''$7'' ''$8'' ''$9'''
            'UserParameter=zbxveeam.discover.jobs[*], powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { Add-PSSnapin VeeamPsSnapin; Import-Module ZbxVeeam -Force; Get-ZbxVeeamWrapper $args }" ''discover'' ''jobs'' ''$1'' ''$2'' ''$3'' ''$4'' ''$5'' ''$6'' ''$7'''
            'UserParameter=zbxveeam.discover.repos[*], powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { Add-PSSnapin VeeamPsSnapin; Import-Module ZbxVeeam -Force; Get-DiscoverRepositories; }"'
            'UserParameter=zbxveeam.job.details[*], powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { Add-PSSnapin VeeamPsSnapin; Import-Module ZbxVeeam -Force; Get-ZbxVeeamWrapper $args}" ''job'' ''details'' ''$1'' ''$2'' ''$3'' ''$4'' ''$5'' ''$6'' ''$7'''
            'UserParameter=zbxveeam.repo.details[*], powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { Add-PSSnapin VeeamPsSnapin; Import-Module ZbxVeeam -Force; Get-ZbxVeeamRepositoryDetails -InstanceUid $args[0] }" ''$1'''
            'UserParameter=zbxveeam.wmi[*], powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { $result = @{}; (Get-WmiObject -Namespace root/veeambs -Query $args[0]).Properties | % { $result[($_.Name)] = $_.Value }; $result | ConvertTo-Json -Compress }" ''$1'''
        )
        Set-Content -Value $content -Path $ZbxVeeamConfFile -Force

        $find = "^Include={0}$" -f $ZbxVeeamConfFile.Replace("\", "\\")
        
        if ( $AddInclude ) {
            $found = 0
            $conf = Get-Content -Path $ZabbixConfFile
            $conf | ForEach-Object {
                if ( $_ -match $find ) {
                    $found = $found + 1
                }
            }

            if ( $found -gt 0 ) {
                #
            }
            else {
                $append = "Include={0}" -f $ZbxVeeamConfFile
                Add-Content -Path $ZabbixConfFile -Value $append
            }
        }

        if ( $NoRestartAgent -eq $false ) {
            Restart-Service "Zabbix Agent" -Force
        }
    }
}
