#
# Module manifest for module 'ZbxVeeam'
#
# Generated by: fischbacher.markus@gmail.com
#
# Generated on: 28.05.2018
#

@{

    # Script module or binary module file associated with this manifest.
    # RootModule        = ''

    # Version number of this module.
    ModuleVersion         = '18.12.03.104956'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID                  = 'f025ccfd-70bc-42ca-87bd-896c185222f7'

    # Author of this module
    Author                = 'fischbacher.markus@gmail.com'

    # Company or vendor of this module
    CompanyName           = 'Unknown'

    # Copyright statement for this module
    Copyright             = '(c) 2018 fischbacher.markus@gmail.com. All rights reserved.'

    # Description of the functionality provided by this module
    Description           = 'Module for monitoring Veeam with Windows Zabbix Agent'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion     = '3.0'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    ProcessorArchitecture = 'None'

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules    = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies    = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @(
        'ZbxVeeam.psm1',
        'Get-DiscoverJobs.psm1',
        'Get-DiscoverRepositories.psm1',
        'Get-DiscoverWmi.psm1',
        'Get-JobDetails.psm1',
        'Get-RepositoryDetails.psm1'
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport     = '*'
    # FunctionsToExport  = @(
    #    'Get-ZbxVeeam',
    #    'Get-ZVDiscoverJobs'
    # )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport       = @()

    # Variables to export from this module
    VariablesToExport     = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport       = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList        = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData           = @{

        Defaults = @{
            Server  = 'localhost'
            Port    = 9392
            Timeout = 5
            Arg1    = 'discover'
            Arg2    = 'jobs'
            Arg3    = '*'
            Arg4    = ''
            Arg5    = ''
            Arg6    = ''
        }

        PSData   = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = @( 'Zabbix', 'Powershell', 'Veeam' )

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/rockaut/ZbxVeeam'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    DefaultCommandPrefix  = 'ZbxVeeam'

}
