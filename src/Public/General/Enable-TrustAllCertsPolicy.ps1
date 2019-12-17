using namespace System
using namespace System.Net
using namespace System.Collections.Generic
using namespace System.Reflection
Function Enable-TrustAllCertsPolicy {
    <#
    .SYNOPSIS
        Trust all SSL certificates even if self-signed, and set protocol to Tls 1.2.
    #>
    [CmdletBinding()]
    Param()


    if (! $SrfPreferences.CertPolicyEnabled) {
        Write-Verbose "[Enable-TrustAllCertsPolicy]: Cert Policy is not enabled. Enabling."
        try {
            [Assembly]::LoadFile($AssemblyList.ApiHelper) >$null 2>&1
        }
        catch {
            throw [Exception] `
                "[Enable-TrustAllCertsPolicy]: Failed to import required library: $($AssemblyList.ApiHelper)"
        }
        [ServicePointManager]::CertificatePolicy = [ApiHelper.TrustAllCertsPolicy]::new()
        [ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
        $SrfPreferences.CertPolicyEnabled = $true
        Write-Verbose "[Enable-TrustAllCertsPolicy]: Cert Policy Enabled."
    } else {
        Write-Verbose "[Enable-TrustAllCertsPolicy]: Cert Policy already enabled."
    }

}