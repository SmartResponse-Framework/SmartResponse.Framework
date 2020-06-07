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
    # Establish Certification Policy Exception
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
    if ($LrtConfig.General.CertPolicyRequired) {
        Write-Verbose "[Enable-TrustAllCertsPolicy]: Cert Policy is not enabled. Enabling."
        try {
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        }
        catch {
            throw [Exception] `
                "[Enable-TrustAllCertsPolicy]: Failed to update System.Net.ServicePointManager::CertificatePolicy to new TrustAllCertsPolicy"
        }
    } else {
        Write-Verbose "[Enable-TrustAllCertsPolicy]: Cert Policy set as Not Required."
    }

    # Set PowerShell to TLS1.2
    [ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
}