# :hammer: The Build Process

## :page_with_curl: `New-TestBuild.ps1`

The `New-TestBuild` script found in the root directory of this repository will satisfy most development use cases. Once a source file has been changed, calling `New-TestBuild` will create a new version of the module which is then immediately imported in the user's PowerShell scope.  Cleanup of old builds can be done by specifying the `-RemoveOld` switch.

## SrfBuilder Overview

The `New-TestBuild` script utilizes a small helper module called `SrfBuilder` created specifically for SmartResponse.Framework.   `SrfBuilder` can also be used to manage builds directly, or to install / uninstall them from the local computer.

The purpose of the `SrfBuilder` module is to facilitate testing, installation and release efforts by providing a consistent and reliable build process. This decouples the repository structure from the module structure, provides automated packaging / manifest creation, and gives developers a "point-in-time" verison of their builds which can be compared during the development process.

What does `SrfBuilder` do?

* A unique Build Id (guid) is assigned to the new build which will be used in the module's manifest file and by other `SrfBuilder` cmdlets to identify the build.
* A unique directory for the Build Id is created in `build\out` . All module files, public and private cmdlets, and`dll` files will be copied to this destination. A module manifest file based on `ModuleInfo.json` and parameters provided to `New-SrfBuild` will be generated in this directory.
* If the `Version` parameter is not provided, the value in `ModuleInfo.json` is used.
* Information about the new build is written to `build/BuildInfo.json`, enabling Pester tests and the `Install-SrfBuild` command to correctly utilize the most recent build when invoked. Running `Get-SrfBuild` will return information on the most recent build.
* A properly structured archive of the build is created in the build directory, ready to be extracted directly into a PowerShell Module directory, e.g. `C:\Program Files\WindowsPowerShell\Modules`.  `Install-SrfBuild` will do this for you.

## SrfBuilder Usage

Before running any SrfBuilder commands, you will need to import the `psm1` file located in the repository's `build` directory.

```PowerShell
PS C:\SmartResponse.Framework> Import-Module .\build\SrfBuilder.psm1
```

## `New-SrfBuild`

Creates a new build for this repository's module source (/src).

**Parameters:**

* `-Version` (x.y.z) Leaving out the version parameter uses the version in `ModuleInfo.json`
* `-ReleaseNotes` Adds a release note to the module's manifest file.

**Example:**

```PowerShell
PS C:\> New-SrfBuild -Version 1.0.6 -ReleaseNotes "Solved Collatz Conjecture"
```

## `Install-SrfBuild`

Installs the SmartResponse.Framework module for all users in the system's PowerShell Modules directory: `c:\Program Files\WindowsPowerShell\Modules`.

* This cmdlet requires administrator privileges, and will throw an exception if the caller is not in the local Administrators group.
* If parameters are omitted, the most recent build is selected for installation, as determined by `build\BuildInfo.json`
* **The cmdlet will stop if the module is already installed, unless the -Force parameter is specified.**
* The `Install-SrfBuild` cmdlet can also install a specific build by supplying the BuildId (guid) or a build archive reference(System.IO.FileInfo)

**Parameters:**

* `-BuildId` Specify a build Guid, or omit to use the most recent build.
* `-Archive` Useful for piping from the `New-SrfBuild` or `Get-SrfBuild` commands.
* `-Force` Removes the existing build from the system, if one exists.

**Example:**

```PowerShell
PS C:\> Install-SrfBuild # install the most recent build

PS C:\> Install-SrfBuild "13f3854b-9efc-44b8-8b08-d3962190604c" # install a specific build ID

PS C:\> New-SrfBuild | Install-SrfBuild  # create a new build and install it
```

SRF installs should be completed using the account that will be leveraged to use the SmartResponse.Framework.  The XML Credentials file is bound to a single user.

## `Uninstall-SrfBuild`

The `UnInstall-SrfBuild` cmdlet removes the SmartResponse.Framework module from `C:\Program Files\WindowsPowerShell\Modules`, and takes no parameters.
Generally you won't need to run this cmdlet directly, as it is used by `Install-SrfBuild` to remove previous versions.

:fire: **Warning**: Due to the way assemblies are handled in Application Domains, an exception will occur when attempting to uninstall / delete the module after it has been imported into a *still-active* application domain.

As a result, it may be necessary to **close all PowerShell / VSCode windows before calling** `Uninstall-SrfBuild` or `Install-SrfBuild -Force`.

**Additional Detail:**

Even the `Remove-Module` command will not unload an assembly (dll file) automatically, and assemblies are not typically freed until the application domain has been disposed (the window closed). It is not *generally* feasible to programmatically remove an assembly from an application domain via a script, and in many cases it would be difficult to tell which of several PowerShell windows might own the AppDomain in question.
