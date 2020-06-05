using assembly System.Net.Http
using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace System.Net.Http

Function Add-LrFileToCase {
    <#
    .SYNOPSIS
        Add-LrFileToCase
    .DESCRIPTION
        Add-LrFileToCase
    .PARAMETER Credential
        PSCredential containing an API Token in the Password field.
        Note: You can bypass the need to provide a Credential by setting
        the preference variable $SrfPreferences.LrDeployment.LrApiCredential
        with a valid Api Token.
    .PARAMETER Id
        The Id of the case for which to add a note.
    .PARAMETER File
        Full path to file to be uploaded.  
    .INPUTS
        Type -> Parameter
    .OUTPUTS
        PSCustomObject representing the (new|modified) LogRhythm object.
    .EXAMPLE
        PS C:\> 
    .NOTES
        LogRhythm-API
    .LINK
        https://github.com/LogRhythm-Tools/LogRhythm.Tools
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [pscredential] $Credential = $SrfPreferences.LrDeployment.LrApiCredential,


        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [object] $Id,


        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $File
    )

    Begin {
        $Me = $MyInvocation.MyCommand.Name

        $BaseUrl = $SrfPreferences.LRDeployment.CaseApiBaseUrl
        $Token = $Credential.GetNetworkCredential().Password

        # Enable self-signed certificates and Tls1.2
        Enable-TrustAllCertsPolicy

        #$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $Headers = [Dictionary[string,string]]::new()
        #$Headers.Add("Content-Type", "multipart/form-data")
        $Headers.Add("Authorization", "Bearer $Token")
    }


    Process {
        # Get Case Id
        $IdInfo = Test-LrCaseIdFormat $Id
        if (! $IdInfo.IsValid) {
            throw [ArgumentException] "Parameter [Id] should be an RFC 4122 formatted string or an integer."
        }

        # Previously Used
        #$FileName = Split-Path -Path $File -Leaf

        # Request URI   
        $RequestUri = $BaseUrl + "/cases/$Id/evidence/file/"

        if (-not (Test-Path $File))
        {
            $errorMessage = ("File {0} missing or unable to read." -f $File)
            $exception =  New-Object System.Exception $errorMessage
			$errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'Add-LrFileToCase', ([System.Management.Automation.ErrorCategory]::InvalidArgument), $File
			$PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        if (-not $ContentType)
        {
            Add-Type -AssemblyName System.Web

            # Identify Target file Mime type
            $mimeType = [System.Web.MimeMapping]::GetMimeMapping($File)
            
            # If a Mime type has been identified, set to mime type.  Else set to octet stream.
            if ($mimeType)
            {
                $ContentType = $mimeType
            }
            else
            {
                $ContentType = "application/octet-stream"
            }
        }

        Add-Type -AssemblyName System.Net.Http
        $Headers = [Dictionary[string,string]]::new()
        $Headers.Add("Authorization", "Bearer $Token")
        $Headers.Add("Content-Type","multipart/form-data")

		$httpClientHandler = New-Object System.Net.Http.HttpClientHandler

        $httpClient = New-Object System.Net.Http.Httpclient $httpClientHandler

        $httpClient.DefaultRequestHeaders.add("Authorization", "Bearer $Token")

        $packageFileStream = New-Object System.IO.FileStream @($File, [System.IO.FileMode]::Open)
        
		$contentDispositionHeaderValue = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
	    $contentDispositionHeaderValue.Name = "file"
		$contentDispositionHeaderValue.FileName = (Split-Path $File -leaf)

        $streamContent = New-Object System.Net.Http.StreamContent $packageFileStream
        $streamContent.Headers.ContentDisposition = $contentDispositionHeaderValue
        $streamContent.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue $ContentType
        
        $content = New-Object System.Net.Http.MultipartFormDataContent
        $content.Add($streamContent)

        try
        {
			$response = $httpClient.PostAsync($RequestUri, $content).Result

			if (!$response.IsSuccessStatusCode)
			{
				$responseBody = $response.Content.ReadAsStringAsync().Result
				$errorMessage = "Status code {0}. Reason {1}. Server reported the following message: {2}." -f $response.StatusCode, $response.ReasonPhrase, $responseBody

				throw [System.Net.Http.HttpRequestException] $errorMessage
			}

			return $response.Content.ReadAsStringAsync().Result
        }
        catch [Exception]
        {
			$PSCmdlet.ThrowTerminatingError($_)
        }
        finally
        {
            if($null -ne $httpClient)
            {
                $httpClient.Dispose()
            }

            if($null -ne $response)
            {
                $response.Dispose()
            }
        }
    }
    END { }
}