<!-- markdownlint-disable MD026 -->
# :dizzy: SmartResponse.Framework :dizzy:

SmartResponse.Framework is a powershell module containing commands (cmdlets) intended primarily for use in LogRhythm SmartResponse Plugin development, but can also be used interactively.  

This is an open source, community-driven project. Pull requests, are welcome and encouraged - please review the contribution guidelines below. Feel free to [submit an issue](https://github.com/SmartResponse-Framework/SmartResponse.Framework/issues) to discuss enhancements, design, bugs, questions or other feedback.

:fire: **Everyone is encouraged to read and contribute to [open design issues](https://github.com/SmartResponse-Framework/SmartResponse.Framework/issues).**

## News: October, 2019

Currently the repository contains only a fraction of the content developed in the original module.  The purpose of this initial commit is to introduce the project to the community, and tackle any initial design considerations.

Release of additional features will follow at a measured pace to ensure they fit the needs of the community and are entirely environment indepdenent.  The module has generally been developed with domain / environment neutrality in mind (it is a framework, afterall) but there are some design decisions that were influenced by time and scope constraints at the initial time of development.

## Getting Started

Getting started is easy, if you have some familiarity with Git and PowerShell.

### Requirements

* OS Requirements: older versions *may* work, but have not been tested.
  * Windows 10 Build 1803 or newer
  * Windows Server 2012 R2 or newer
* PowerShell Version 5.1+
* Remote Server Administration Tools + ActiveDirectory PowerShell Module.

### Get and build the module

```powershell
PS> git clone https://github.com/SmartResponse-Framework/SmartResponse.Framework
PS> cd SmartResponse.Framework
PS> .\New-TestBuild.ps1
```

You should now have a working copy of the module in your current PowerShell environment!

:hammer: For more on how **module builds** work, please review the [Build Process](build/readme.md).

### Configuration

Currently there is a little configuration required for some cmdlets to function properly. This design is [open to discussion here](https://github.com/SmartResponse-Framework/SmartResponse.Framework/issues/1).

The configuration file is located in the repository under `~/src/include/SrfPreferences.json`.

In order for the LogRhythm API commands to work, you will need to fill out the following section, save the file, and rebuild the module with the `New-TestBuild.ps1` script.

```json
"LRDeployment": {
    "AdminApiBaseUrl": "https://server.domain.com:8501/lr-admin-api",
    "CaseApiBaseUrl": "https://server.domain.com:8501/lr-case-api",
    "ApiVaultId": "121212",
    "PlatformManager": "server.domain.com",
    "WebConsole": "logrhythm.domain.com",
    "SrpHost": "server.domain.com"
}
```


### Running a command

*An example of one of the LogRhythm Case Commands*

First we will need to get our API Token into a credential. The way I do this is by requesting the token from our SecretServer installation by way of the `Get-Secret` cmdlet in this module.  You can also do this by pasting your token into a PSCredential object like so:

```powershell
PS> $password = Read-Host -Prompt "token" -AsSecureString
pass: *****(paste token)
$token = [pscredential]::new("lr", $pass)
```

Then we can run one of the LogRhythm Case Commands. In this example, a playbook imported from the LogRhythm community about Malware is returned. Any playbooks with Malware in the name will also be returned in an array of playbook objects.

```powershell
Get-LrPlaybooks -Credential $token -Name "Malware"

    id            : BC3B367A-28CB-4E65-BE74-3B4ED5077976
    name          : Malware Incident
    description   : Use this Playbook when responding to malicious events that use an exploit code targeting vulnerable services instead of using a compiled malicious binary, typically known as a virus.
    permissions   : @{read=publicAllUsers; write=publicGlobalAdmin}
    owner         : @{number=35; name=Smith, Bob; disabled=False}
    retired       : False
    entities      : {@{number=1; name=Primary Site}}
    dateCreated   : 2019-04-10T15:27:54.1499666Z
    dateUpdated   : 2019-09-11T14:30:53.1726298Z
    lastUpdatedBy : @{number=35; name=Smith, Bob; disabled=False}
    tags          : {@{number=66; text=APT}, @{number=5; text=Malware}}
```

Check out more info on the command with:

`PS> Get-Help Get-LrPlaybooks -Full`

---------

## Contributing

Contributions are welcome. Please review the [Contributing](CONTRIBUTING.md) guide and the [Code Style](CODESTYLE.md) guide.

