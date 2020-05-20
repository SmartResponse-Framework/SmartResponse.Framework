using namespace System
using namespace System.IO
using namespace System.Collections.Generic


<#
.SYNOPSIS
    xxxx
.DESCRIPTION
    xxxx
.PARAMETER param1
    xxxx
.PARAMETER param2
    xxxx
.INPUTS
    xxxx
.OUTPUTS
    xxxx
.EXAMPLE
    xxxx
.EXAMPLE
    xxxx
.LINK
    https://github.com/SmartResponse-Framework/SmartResponse.Framework        
#>

[CmdletBinding()]
Param(
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        Position = 0
    )]
    [string] $param1
)

# Install.ps1 (root directory)
#   a. Prompts for PM Name, LR Token, install scope (User/System)
# 	b. Calls Install-LrPs.ps1 w/ install scope
# 	c. Calls New-LrPsConfig with PM name and secure string api key

$LrPmHostName = ""
$LrToken = ""
$InstallScope = ""

