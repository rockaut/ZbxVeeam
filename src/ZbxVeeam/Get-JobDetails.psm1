function Get-JobDetails {
    <#
	.SYNOPSIS
	.DESCRIPTION
	.PARAMETER Types
	.EXAMPLE
    #>
    param(
        $JobName = '*',
        $Processing = 'out'
    )
    Begin {
        if ( $JobName -eq 'all' -or $JobName -eq '*' -or $JobName -eq $null ) {
            $JobName = '*'
        }
        if ( $Processing -notin @('out', 'send', 'raw', 'cache') ) {
            $Processing = 'out'
        }

        $dateBase = Get-Date -Date "01/01/1970"
    }
    Process {
    
        $jobs = Get-VBRJob -Name $JobName

        $jobs | ForEach-Object {
            $job = $_

            $data = @{}
            $data['Info'] = @{}
            $data['ScheduleOptions'] = @{}

            $data['Name'] = $job.Name
            $data['Id'] = $job.Id
            $data['Server'] = (Get-VBRServerSession).Server.ToString()

            $data['IsRunning'] = $job.IsRunning
            $data['IsRequireRetry'] = $job.IsRequireRetry
            $data['IsScheduleEnabled'] = $job.IsScheduleEnabled
            $data['IsChainedJob'] = ($job.PreviousJobIdInScheduleChain -ne $null)
            $data['HasLinkedJobs'] = ($job.LinkedJobs.Count -gt 0 )
            $data['RetryCount'] = 0
        
            $data['Info']['LatestStatus'] = $job.Info.LatestStatus
            $data['Info']['IncludedSize'] = $job.Info.IncludedSize
            $data['Info']['ExcludedSize'] = $job.Info.ExcludedSize

            $data['ScheduleOptions']['LatestRun'] = [Math]::Floor((New-TimeSpan -Start $dateBase -End $job.ScheduleOptions.LatestRunLocal).TotalSeconds)

            if ( $job.ScheduleOptions.NextRun -ne "" ) {
                $nextDate = Convert-DateString $job.ScheduleOptions.NextRun "MM/dd/yyyy HH:mm:ss"
                $data['ScheduleOptions']['NextRun'] = [Math]::Floor((New-TimeSpan -Start $dateBase -End $nextDate).TotalSeconds)
            }
            else {
                $data['ScheduleOptions']['NextRun'] = ""
            }

            $lastsession = $job.FindLastSession()

            $fullDuration = 0
            $normalDuration = 0
            $retryDuration = 0

            if ( $lastSession -ne $null ) {
                $data['lastSession'] = @{}
                $data['lastSession']['Info'] = @{}
                $data['lastSession']['Stats'] = @{}

                $data['lastSession']['Result'] = $lastsession.Result
                $data['lastSession']['State'] = $lastsession.State
                $data['lastSession']['BaseProgress'] = $lastsession.BaseProgress
                $data['lastSession']['IsCompleted'] = $lastsession.IsCompleted
                $data['lastSession']['IsWorking'] = $lastsession.IsWorking
            
                $data['lastSession']['Info']['Failures'] = $lastsession.SessionInfo.Failures
                $data['lastSession']['Info']['Warnings'] = $lastsession.SessionInfo.Warnings
                $data['lastSession']['Info']['BackedUpSize'] = $lastsession.SessionInfo.BackedUpSize
                $data['lastSession']['Info']['BackupTotalSize'] = $lastsession.SessionInfo.BackupTotalSize
                $data['lastSession']['Info']['IsRetryMode'] = $lastsession.SessionInfo.IsRetryMode.ToString()
                $data['lastSession']['Info']['IsActiveFullMode'] = $lastsession.SessionInfo.IsActiveFullMode
                $data['lastSession']['Info']['IsFullMode'] = $lastsession.SessionInfo.IsFullMode
                $data['lastSession']['Info']['WillBeRetried'] = $lastsession.SessionInfo.WillBeRetried
                $data['lastSession']['Info']['RunManually'] = $lastsession.SessionInfo.RunManually

                $data['lastSession']['Info']['TotalObjects'] = $lastsession.SessionInfo.Progress.TotalObjects
                $data['lastSession']['Info']['AvgSpeed'] = $lastsession.SessionInfo.Progress.AvgSpeed
                $data['lastSession']['Info']['TransferedSize'] = $lastsession.SessionInfo.Progress.TransferedSize
                $data['lastSession']['Info']['Duration'] = $lastsession.SessionInfo.Progress.Duration.TotalSeconds
                $data['lastSession']['Info']['TotalSize'] = $lastsession.SessionInfo.Progress.TotalSize
            
                $data['lastSession']['Stats']['DataSize'] = $lastsession.BackupStats.DataSize
                $data['lastSession']['Stats']['DedupRatio'] = $lastsession.BackupStats.DedupRatio
                $data['lastSession']['Stats']['CompressRatio'] = $lastsession.BackupStats.CompressRatio

                $data['RetryCount'] = ($lastsession.GetOriginalAndRetrySessions($true).Count - 1)

            } else {
                $data['lastSession'] = @{}
                $data['lastSession']['Info'] = @{}
                $data['lastSession']['Stats'] = @{}

                $data['lastSession']['Result'] = "none"
                $data['lastSession']['State'] = "none"
                $data['lastSession']['BaseProgress'] = 0
                $data['lastSession']['IsCompleted'] = $true
                $data['lastSession']['IsWorking'] = $false
            
                $data['lastSession']['Info']['Failures'] = 0
                $data['lastSession']['Info']['Warnings'] = 0
                $data['lastSession']['Info']['BackedUpSize'] = 0
                $data['lastSession']['Info']['BackupTotalSize'] = 0
                $data['lastSession']['Info']['IsRetryMode'] = $false
                $data['lastSession']['Info']['IsActiveFullMode'] = $false
                $data['lastSession']['Info']['IsFullMode'] = $false
                $data['lastSession']['Info']['WillBeRetried'] = $false
                $data['lastSession']['Info']['RunManually'] = $false

                $data['lastSession']['Info']['TotalObjects'] = 0
                $data['lastSession']['Info']['AvgSpeed'] = 0
                $data['lastSession']['Info']['TransferedSize'] = 0
                $data['lastSession']['Info']['Duration'] = 0
                $data['lastSession']['Info']['TotalSize'] = 0
            
                $data['lastSession']['Stats']['DataSize'] = 0
                $data['lastSession']['Stats']['DedupRatio'] = 0
                $data['lastSession']['Stats']['CompressRatio'] = 0

                $data['RetryCount'] = 0
            }

            if ( $lastsession.IsActiveFullMode -or $lastsession.IsFullMode ) {
                if ( $lastsession.IsCompleted ) {
                    $fullDuration = $lastsession.SessionInfo.Progress.Duration.TotalSeconds
                }
            }
            else {
                if ( $lastsession.IsCompleted ) {
                    $normalDuration = $lastsession.SessionInfo.Progress.Duration.TotalSeconds
                }
                if ( $lastsession.SessionInfo.IsRetryMode ) {
                    $normalDuration = ($lastSession.GetOriginalAndRetrySessions($true))[0].Progress.Duration.TotalSeconds
                }
            }

            if ( $lastsession.SessionInfo.IsRetryMode ) {
                if ( $lastsession.IsCompleted ) {
                    $retryDuration = $lastsession.SessionInfo.Progress.Duration.TotalSeconds
                }

                $data['lastSession']['Info']['TotalObjects'] = ( $lastSession.GetOriginalAndRetrySessions($true).SessionInfo.Progress.TotalObjects | Measure-Object -Sum ).Sum
                $data['lastSession']['Info']['Failures'] = ( $lastSession.GetOriginalAndRetrySessions($true).SessionInfo.Failures | Measure-Object -Sum ).Sum
                $data['lastSession']['Info']['Warnings'] = ( $lastSession.GetOriginalAndRetrySessions($true).SessionInfo.Warnings | Measure-Object -Sum ).Sum

                $data['lastSession']['Info']['Duration'] = ( $lastSession.GetOriginalAndRetrySessions($true).Progress.Duration.TotalSeconds | Measure-Object -Sum ).Sum
                $data['lastSession']['Info']['TotalSize'] = ( $lastSession.GetOriginalAndRetrySessions($true).Progress.TotalSize | Measure-Object -Sum ).Sum
                $data['lastSession']['Stats']['DataSize'] = ( $lastSession.GetOriginalAndRetrySessions($true).BackupStats.DataSize | Measure-Object -Sum ).Sum
                $data['lastSession']['Info']['TransferedSize'] = ( $lastSession.GetOriginalAndRetrySessions($true).Progress.TransferedSize | Measure-Object -Sum ).Sum
                $data['lastSession']['Info']['AvgSpeed'] = ( $lastSession.GetOriginalAndRetrySessions($true).Progress.AvgSpeed | where { $_ -gt 0 } | Measure-Object -Sum ).Sum

            }

            $data['Info']['FullDuration'] = $fullDuration
            $data['Info']['NormalDuration'] = $normalDuration
            $data['Info']['RetryDuration'] = $retryDuration

            $json = $data | ConvertTo-Json -Compress
        
            if ( $Processing -eq "send" ) {
                $json = $json.Replace('"', '\"')
                $result = & "C:\Program Files\zabbix_agent\bin\win64\zabbix_sender.exe" -c "C:\Program Files\zabbix_agent\conf\zabbix_agentd.win.conf" -s $job.Id -k "backupjob-data" -o $json -v
                Write-Output $job.Name
                Write-Output $result
            }
            elseif ( $Processing -eq "out" ) {
                Write-Output $json
            }
            elseif ( $Processing -eq "raw" ) {
                Write-Output $job
            } else {
                $path = "C:\Windows\Temp\{0}.data.json" -f $job.Id
                $json | Out-File -FilePath $path -Encoding utf8 -Force
            }

            
        } # End foreach jobs

    } # End process
}