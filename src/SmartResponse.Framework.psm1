
#region: Module Info                                                                     
# Module Name: To make it easier to change the name of the module.
# NOTE: There is a corresponding set of variables in the build module's psm1.  If these
#       are changed, then the variables there should be updated to the same.
$ModuleName = "LrPs"
$PreferencesFileName = $ModuleName + ".preferences.json"


# [Namespaces]: Directories to include in this module
$Namespaces = @(
    "Public",
    "Private"
)

# List of Packages (.dll files) used by module.
$AssemblyList = [PSCustomObject]@{
    ApiHelper = $(Join-Path $PSScriptRoot "ApiHelper.dll")
}

# Includes Dir
$SrfIncludes = [System.IO.DirectoryInfo]::new((Join-Path -Path $PSScriptRoot -ChildPath "Include"))
#endregion



#region: Load Preferences                                                                
$PrefPath = Join-Path `
    -Path ([Environment]::GetFolderPath("LocalApplicationData"))`
    -ChildPath $ModuleName | Join-Path -ChildPath $PreferencesFileName
$PrefInfo = [System.IO.FileInfo]::new($PrefPath)

if ($PrefInfo.Exists) {
    $SrfPreferences = Get-Content -Path $PrefInfo.FullName -Raw | ConvertFrom-Json
} else {
    Write-Host "Warning: Unable to locate preferences directory - module will load copy from installation/include directory."
    $SrfPreferences = Get-Content -Path `
        (Join-Path -Path $SrfIncludes.FullName -ChildPath $PreferencesFileName) -Raw | ConvertFrom-Json
}
#endregion



#region: Module Reference Object Variables                                               
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
    Write-Host "  > LogRhythm API Key Loaded." -ForegroundColor Green
}
catch [System.IO.FileNotFoundException] {
    Write-Host "Warning: LogRhythm API Credential not found." -ForegroundColor Yellow
    Write-Host "LogRhythm cmdlets will need to specify the '-Credential' option in order to function." `
    -ForegroundColor Yellow
}
catch [System.Security.Cryptography.CryptographicException] {
    Write-Host "Unable to load key, insufficient permissions. Run Setup script." `
    -ForegroundColor Yellow
}
catch [System.Exception] {
    Write-Host "Unexpected error while attempting to load LogRhythm API Credential."
    Write-Host "LogRhythm cmdlets will need to specify the '-Credential' option in order to function." `
    -ForegroundColor Yellow
}
#endregion



#region: Export Module Members                                                           
Export-ModuleMember -Variable ModuleName
Export-ModuleMember -Variable SrfPreferences
Export-ModuleMember -Variable LrCaseStatus
Export-ModuleMember -Variable AssemblyList
Export-ModuleMember -Variable HttpMethod
Export-ModuleMember -Variable HttpContentType
Export-ModuleMember -Function $Includes["Public"].BaseName
#endregion