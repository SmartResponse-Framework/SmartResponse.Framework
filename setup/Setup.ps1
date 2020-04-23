using namespace System
using namespace System.IO
using namespace System.Xml
using namespace System.Collections.Generic
using namespace Windows.Markup


[CmdletBinding()]Param()
Add-Type -AssemblyName PresentationFramework


. (Join-Path -Path $PSScriptRoot -ChildPath "Install-LrPs.ps1")

#create window
$InputXaml = Get-Content (Join-Path -Path $PSScriptRoot -ChildPath "MainWindow.xaml") -Raw
$InputXaml = $InputXaml -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$Xaml = $InputXaml


#Read XAML
$reader = [XmlNodeReader]::new($Xaml)
try {
    $Window = [Windows.Markup.XamlReader    ]::Load($reader)
} catch {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}


# Create variables based on form control names.
$Xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)"
    try {
        Set-Variable -Name "form_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}
Get-Variable form_*


#region: Button Event                                                                    
$form_Btn_Install.Add_Click({
    #clear the result box
    $form_TxtBx_Output.Text = ""
    
    # LOGIC
})
 
# $var_txtComputer.Text = $env:COMPUTERNAME
#endregion


$Null = $Window.ShowDialog()