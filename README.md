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

---------

## Contributing

Contributions are welcome. Please review the [Contributing](CONTRIBUTING.md) guide and the [Code Style](CODESTYLE.md) guide.

