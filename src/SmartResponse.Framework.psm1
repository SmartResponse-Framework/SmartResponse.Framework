#region: Module Data
# [Namespaces]: Directories to include in this module
$Namespaces = @(
    "Public",
    "Private"
)


# List of Packages (.dll files) used by module.
<#
$AssemblyList = [PSCustomObject]@{
    ApiHelper = $(Join-Path $PSScriptRoot "ApiHelper.dll")
}
#>

# Load Module Preferences
$SrfIncludes = [System.IO.DirectoryInfo]::new((Join-Path $PSScriptRoot "Include"))
$SrfPreferences = Get-Content -Path (Join-Path $SrfIncludes.FullName "SrfPreferences.json") -Raw | ConvertFrom-Json
$SecretList = $SrfPreferences.Vault.SecretList


# LogRhythm Case Vars
# 1 - [Case]      Created
# 2 - [Case]      Completed
# 3 - [Incident]  Open
# 4 - [Incident]  Mitigated
# 5 - [Incident]  Resolved
$LrCaseStatus = [PSCustomObject]@{
    Created     = 1
    Completed   = 2
    Open        = 3
    Mitigated   = 4
    Resolved    = 5
}


# HTTP Vars
$HttpMethod = [PSCustomObject]@{
    Get     = "Get"
    Head    = "Head"
    Post    = "Post"
    Put     = "Put"
    Delete  = "Delete"
    Trace   = "Trace"
    Options = "Options"
    Merge   = "Merge"
    Patch   = "Patch"
}


$HttpContentType = [PSCustomObject]@{
    Json        = "application/json"
    Text        = "text/plain"
    Html        = "text/html"
    Xml         = "application/xml"
    JavaScript  = "application/javascript"
    FormUrl     = "application/x-www-form-urlencoded"
    FormData    = "multipart/form-data"
}


# Azure Vars
$RegexLibrary = [PSCustomObject]@{
    URI      = [regex]::new("(https:\/\/)?([\w\-])+\.{1}([a-zA-Z]{2,63})([\/\w-]*)*\/?\??([^#\n\r]*)?#?([^\n\r]*)")
    GUID     = [regex]::new("^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}$")
    SECRETID = [regex]::new("^\d{3,6}$")
    NAME     = [regex]::new("^.*?$")
}


# Azure AuthContext
$AuthContext_Schema = [PSCustomObject]@{
    Name        = $RegexLibrary.NAME
    TenantId    = $RegexLibrary.GUID
    SecretId    = $RegexLibrary.SECRETID
    OAuth2Uri   = $RegexLibrary.URI
    ResourceUri = $RegexLibrary.URI
}
#endregion



#region: Load AD Module
if (-not (Get-Module ActiveDirectory)) {
    # Module Not Loaded
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        Write-Host "Could not locate ActiveDirectory module, attempting to install." -ForegroundColor Yellow
        
        # I've tried a couple variations, but perhaps this shouldn't be done here.
        # Simply fail if no ActiveDirectory module is found to import??

        # Install - Servers
        if (Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue) {
            Install-WindowsFeature -Name "RSAT-AD-PowerShell"
        # Install - Workstations
        } elseif (Get-Command Add-WindowsCapability -ErrorAction SilentlyContinue) {
            Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
        } else {
            Write-Host "Unable to enable RSAT tools. Please install / enable and then re-import this module." -ForegroundColor Yellow
        }
    } else {
        try {
            # ActiveDirectory module found - attempt to import
            Import-Module ActiveDirectory -Force -WarningAction SilentlyContinue | Out-Null
        }
        catch {
            Write-Host "Unable to import ActiveDirectory module." -ForegroundColor Yellow
            throw $_
        }
    }
}
#endregion



#region: Import Functions
# Build Import Hash Table
$Includes = @{}
foreach ($namespace in $Namespaces) {
    $Includes.Add($namespace, @(Get-ChildItem -Recurse -Include *.ps1 -Path $PSScriptRoot\$namespace -ErrorAction SilentlyContinue))
}
# Run Import
foreach ($include in $Includes.GetEnumerator()) {
    foreach ($file in $include.Value) {
        try {
            . $file.FullName
        }
        catch {
            Write-Error "  - Failed to import function $($file.BaseName): $_"
        }
    }
}
#endregion


# Export Module Members
Export-ModuleMember -Variable SrfPreferences
Export-ModuleMember -Variable SecretList
Export-ModuleMember -Variable LrCaseStatus
#Export-ModuleMember -Variable AssemblyList
Export-ModuleMember -Variable HttpMethod
Export-ModuleMember -Variable HttpContentType
Export-ModuleMember -Function $Includes["Public"].BaseName