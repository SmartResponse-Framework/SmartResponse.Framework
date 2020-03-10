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


add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
<#
    if (! $SrfPreferences.CertPolicyEnabled) {
        Write-Verbose "[Enable-TrustAllCertsPolicy]: DLL - Cert Policy is not enabled. Enabling."
        try {
            [Assembly]::LoadFile($AssemblyList.ApiHelper) >$null 2>&1
        }
        catch {
            throw [Exception] `
                "[Enable-TrustAllCertsPolicy]: DLL - Failed to import required library: $($AssemblyList.ApiHelper)"
        }
        [ServicePointManager]::CertificatePolicy = [ApiHelper.TrustAllCertsPolicy]::new()
        [ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
        $SrfPreferences.CertPolicyEnabled = $true
        Write-Verbose "[Enable-TrustAllCertsPolicy]: DLL - Cert Policy Enabled."
    } else {
        Write-Verbose "[Enable-TrustAllCertsPolicy]: DLL - Cert Policy already enabled."
    }
#>
    if ($SrfPreferences.CertPolicyRequired) {
        Write-Verbose "[Enable-TrustAllCertsPolicy]: Cert Policy is not enabled. Enabling."
        try {
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        }
        catch {
            throw [Exception] `
                "[Enable-TrustAllCertsPolicy]: Failed to update System.Net.ServicePointManager::CertificatePolicy to new TrustAllCertsPolicy"
        }
        [ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
    } else {
        Write-Verbose "[Enable-TrustAllCertsPolicy]: Cert Policy set as Not Required."
    }

}