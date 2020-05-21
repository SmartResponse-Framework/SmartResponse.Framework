
#region: Module Info                                                                     
# Module Name: To make it easier to change the name of the module.
# NOTE: These two variables should be set exactly the same as they appear in setup\New-LrtConfig!
#       The name of the file may be $ModuleName.config.json, but the object is still called
#       [SrfPreferences] - too many things reference that currently to be changed without extra testing.
$ModuleName = "Lrt"
$PreferencesFileName = $ModuleName + ".config.json"


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
$IncludeDirPath = [System.IO.DirectoryInfo]::new((Join-Path -Path $PSScriptRoot -ChildPath "Include"))
#endregion



#region: Load Preferences                                                                
$ConfigDirPath = Join-Path `
    -Path ([Environment]::GetFolderPath("LocalApplicationData"))`
    -ChildPath $ModuleName

$ConfigFileInfo = [System.IO.FileInfo]::new((Join-Path -Path $ConfigDirPath -ChildPath $PreferencesFileName))

# Try to load the Config File from Local AppData, fallback to the copy in the install directory.
if ($ConfigFileInfo.Exists) {
    $SrfPreferences = Get-Content -Path $ConfigFileInfo.FullName -Raw | ConvertFrom-Json
} else {
    Write-Host "Warning: Unable to locate preferences directory - module will load copy from installation/include directory."
    $SrfPreferences = Get-Content -Path `
        (Join-Path -Path $IncludeDirPath.FullName -ChildPath $PreferencesFileName) -Raw | ConvertFrom-Json
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

$KeyPath = Join-Path -Path $ConfigDirPath -ChildPath "LrApiToken.xml"

try {
    $SrfPreferences.LrDeployment.LrApiCredential = Import-Clixml -Path $KeyPath
}
catch [System.IO.FileNotFoundException] {
    Write-Host "Warning: LrApiToken.xml not found in $ConfigDirPath" -ForegroundColor Yellow
    Write-Host "LogRhythm cmdlets will need to specify the '-Credential' option in order to function." `
    -ForegroundColor Yellow
}
catch [System.Security.Cryptography.CryptographicException] {
    Write-Host "Unable to load key, insufficient permissions. Run the Setup script again to create a new credential file." `
    -ForegroundColor Yellow
}
catch [System.Exception] {
    Write-Host "Unexpected error while attempting to load LogRhythm API Credential." -ForegroundColor Yellow
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