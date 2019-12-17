<!-- markdownlint-disable MD024 -->
# :notes: Version 1.0.8

## Change Log

This update brings many LogRhythm API cmdlets to the framework, primarily those required for automated case creation.

The following cmdlets have been added:

### Case Management

- Add-LrAlarmToCase.ps1
- Add-LrPlaybookToCase.ps1
- Add-LrTagsToCase.ps1
- Format-LrCaseListSummary.ps1
- Get-LrCaseById.ps1
- Get-LrCases.ps1
- Get-LrPlaybookById.ps1
- Get-LrPlaybooks.ps1
- Get-LrTags.ps1
- Get-LrUsers.ps1
- Get-PIFTypeName.ps1
- New-LRCase.ps1
- Test-LrCaseIdFormat.ps1
- Update-LrCaseStatus.ps1

### AIE Drilldown

- Get-LrAieDrilldown.ps1

### Lists

- Get-LrList.ps1
- Get-LRListGuidByName.ps1

# :bug: Version 1.0.7

## Change Log

### New: Preferences

I've added a "preferences" concept to the module, to store install-specific information such as mail server, html email templates, secret ID lists, etc.  

Currently this exists in the ModuleRoot folder (`c:\Program Files\WindowsPowerShell\Modules\SmartResponse.Framework\Include\SrfPreferences.json`), though may be configurable in the future.

### New: `ApiHelper.dll`

Created a new class `AuthContext` that contains information about Azure Authentication contexts.
This type has all of the information required to obtain an Azure OAuth 2 token, without
exposing any sensitive information, as the Client Secret is obtained from Secret Server.

The current structure of the `AuthContext` type is:

```csharp
    public string Name { get; set; }
    public Guid TenantId { get; set; }
    public string SecretId { get; set; }
    public Uri OAuth2Uri { get; set; }
    public Uri ResourceUri { get; set; }
```

And a new Authentication Context Object can be created as follows:

`New-AuthContext ((Get-Content c:\path\to\auth.json) | ImportFrom-Json)`

The format of the json file is:

```javascript
{
    "Name": "ATP-API",
    "TenantId": "d441ad83-6235-46d6-ab1a-89744a91b1d8",
    "SecretId": 82381,
    "OAuth2Uri": "https://login.windows.net/[TenantId]/oauth2/token",
    "ResourceUri": "https://api.securitycenter.windows.com"
}
```

### New Cmdlet: `Enable-TrustAllCertsPolicy`

Added a cmdlet that will load ApiHelper.dll and initiate the TrustAllCerts policy, as well as use Tls 1.2.

This removes the need for any scripts to rely on the old hack of manually adding a trust all certs policy to each script.

If you want to use the policy, simply call `Enable-TrustAllCertsPolicy` early in your script - that's ALL!

### New Exported Variable: AssemblyList

Contains a list of .dll files that can be loaded.  There is only one for now (apihelper.dll)

Structure:

```powershell
# List of Packages (.dll files) used by module.
$AssemblyList = [PSCustomObject]@{
    ApiHelper = $(Join-Path $PSScriptRoot "ApiHelper.dll")
}
```

### `Get-ADUSerInfo`

- Added field `SamAccountName`
- Added field `EmailAddress`

New `[PSCustomObject] Get-ADUSerInfo` structure:

```ini
- Name:             [string]    Common Name (CN)
- SamAccountName:   [string]    Account Logon (7Letter)
- EmailAddress:     [string]    SMTP Address
- Exists:           [boolean]   User Exists
- Enabled:          [boolean]   User is Enabled
- LockedOut:        [boolean]   Account is Locked
- PasswordExpired:  [boolean]   Password is Expired
- PasswordAge:      [integer]   Days since Password Changed
- HasManager:       [boolean]   Manager is Assigned
- ManagerName:      [boolean]   Manager Common Name
- ManagerEmail:     [string]    Manager SMTP Address
- IsSvcAccount:     [boolean]   Name like Svc* or in ServiceAccount OU
- OrgUnits:         [List]      OU Hierarchy
- ADUser:           [ADUser]    Full ADUser Object
```

### `Test-SrfADCredential`

- You can now send the credential to be tested via pipeline.

---

### New Cmdlet: `Test-SrfADUserOrGroup`

Used to determine if a given Identity represents a User, Group, or nothing.

Returns a System.Type object representing [Microsoft.ActiveDirectory.Management.ADGroup] or [Microsoft.ActiveDirectory.Management.ADGroup]

---

### New Cmdlet: `Send-SOCMessage`

The Send-SOCMessage cmdlet sends an html formatted email. The intent is to make it easier to use well-formed Html templates in automated email messages.

### Pester Test Change: `Initialize-Test`

`Initialize-Test` should now be called in all Pester test scripts to load the current build as opposed to the current install.

>>>>>>>>>>>>> (ADD NEW 1.0.7 FEATURES HERE!)

========================================================================================

# :tropical_fish: Version 1.0.6

## Change Log

- **`SrfBuilder`**: Major overhaul of the Build Module Tool (now called `SrfBuilder`), which is much simpler to use.
For more options, see [SrfBuilder readme](./readme.md).

- **`Get-Secret`**: has been updated to include parameters for specifying a credential for authentication
to Secret Server. This can either be a `PSCredential` object or a path to serialized `PSCredential`.
Error handling has been cleaned up and the cmdlet should now **always be called in a `Try/Catch` block**
when used in scripts.

- **`ApiHelper`**: I have created a small C# library which contains API-related classes that assist in consuming
web services.  Only one for now, an `ICertificatePolicy` that enables powershell to trust self-signed SSL
certificates without needing to dump C# code directly into PowerShell.

- **`Pester`**: Unit tests have been overhauled for `Write-IfVerbose` and `Get-Secret`.

- **Directory Structure:** Updated to reflect growing number of cmdlets added to the FrameWork. The src\Public
folder will contain directories to group cmdlets by topic, such as Remoting and ActiveDirectory.

- **Azure** utilities added to module. These are still considered experimental but will be complete in version
1.0.7.
