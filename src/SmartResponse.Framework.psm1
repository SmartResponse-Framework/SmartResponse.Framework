#region: Module Data                                                                     
# [Namespaces]: Directories to include in this module
$Namespaces = @(
    "Public",
    "Private"
)


# Load Module Preferences
$SrfIncludes = [System.IO.DirectoryInfo]::new((Join-Path -Path $PSScriptRoot -ChildPath "Include"))
$SrfPreferences = Get-Content -Path (Join-Path -Path $SrfIncludes.FullName -ChildPath "SrfPreferences.json") -Raw | ConvertFrom-Json



# LogRhythm Case Vars
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

#region: Import API Keys                                                                 
# LogRhythm API Key
$KeyPath = $SrfPreferences.LrDeployment.LrApiCredentialPath

try {
    $SrfPreferences.LrDeployment.LrApiCredential = Import-Clixml -Path $KeyPath
}
catch [System.IO.FileNotFoundException] {
    Write-Host "Warning: LogRhythm API Credential not found." -ForegroundColor Yellow
    Write-Host "LogRhythm cmdlets will need to specify the '-Credential' option in order to function." `
    -ForegroundColor Yellow
}
catch [System.Security.Cryptography.CryptographicException] {
    Write-Host "Unable to load key, insufficient permissions.  Did you run setup.ps1 as this user?" `
    -ForegroundColor Yellow
}
catch [Exception] {
    Write-Host "Unexpected error while attempting to load LogRhythm API Credential."
    Write-Host "LogRhythm cmdlets will need to specify the '-Credential' option in order to function." `
    -ForegroundColor Yellow
}
Write-Verbose "[ LogRhythm API Key Set ]"
#endregion


# Export Module Members
Export-ModuleMember -Variable SrfPreferences
Export-ModuleMember -Variable LrCaseStatus
Export-ModuleMember -Variable HttpMethod
Export-ModuleMember -Variable HttpContentType
Export-ModuleMember -Function $Includes["Public"].BaseName