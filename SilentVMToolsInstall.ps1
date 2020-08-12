<#
.Synopsis
  This Powershell script controls silent install of VMTools Typical Install if used within PCLM
  
.DESCRIPTION
  Controls silent install of VMTools Typical Install if used within PCLM or build process like MDT

.AUTHOR
  Phil Helmling

.EXAMPLE
  .\SilentVMToolsInstall.ps1
#>

$current_path = $PSScriptRoot;
if($PSScriptRoot -eq ""){
    #PSScriptRoot only popuates if the script is being run.  Default to default location if empty
    $current_path = "C:\Temp";
} 

# Add exclusion capabilities
#$exclude = "Hgfs"

function Get-InstalledStatus {
    $uninstallPath = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "VMware Tools" }).PSChildName
    if(!uninstallPath) {
        $output = $false
    } else {
        $output = $true
    }
    return $output
}
$installed = Get-InstalledStatus

if($installed -eq $false) {
    Write-host "Running Install Process"
    Start-Process -filepath $current_path\Setup.exe -ArgumentList "/s /v`"/qn /norestart`"" -wait
    #Start-Process -filepath $current_path\Setup.exe -ArgumentList "/s /v`"ADDLOCAL=ALL REMOVE=`"$exclude`" /qn /norestart`"" -wait

    Start-Sleep -Seconds 10
    $installed = Get-InstalledStatus

    while($installed -eq $false) {
        Start-Sleep -Seconds 10
        $installed = Get-InstalledStatus
    }
}
