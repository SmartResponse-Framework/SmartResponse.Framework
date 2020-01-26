function DefaultUrlFound {
    Param(
        [Parameter(Mandatory = $true, Position = 0)] [Object] $Pref
    )
    
    $DefaultUrl = "^https:\/\/SERVER:8501\/lr-.*?api$"
    $FoundDefaultValue = $false

    if ($Pref.AdminApiBaseUrl -match $DefaultUrl) {
        $FoundDefaultValue = $true
    }
    if ($Pref.AdminApiBaseUrl -match $DefaultUrl) {
        $FoundDefaultValue = $true
    }
    if ($Pref.AieApiUrl -match $DefaultUrl) {
        $FoundDefaultValue = $true
    }
    return $FoundDefaultValue
}