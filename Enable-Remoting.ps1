#Short script to enable psremoting
function Enable-Remoting {
  [CmdletBinding()]
  param([Parameter(mandatory = $true)]
    [System.String[]]$Computer)
  foreach ($Comp in $Computer) {
    ##Requires -PSEdition Desktop
    #Install the needed modules
    Write-Host "Getting Required Modules";
    if (-not (Get-Command -Module CredentialManager)) {
      Install-Module -Name CredentialManager -AllowClobber -Force
      Import-Module -Name CredentialManager -Global -Force
    }

    # First Check if we already have the saved credentials
    if (-not (Get-StoredCredential -Target 'PSCreds')) {
      # Get Credentials for remote connection
      $PSCreds = New-StoredCredential -Comment 'PSCreds' -Credentials $(Get-Credential) -Target 'PSCreds'
    }


    #Check if already added to path
    Write-Host "Checking if we can call psexec";
    $found = [bool](Get-Command -ErrorAction Ignore -Type Application PsExec.exe)
    if (-not ($found)) {
      Write-Host "Adding Psexec to Path";

      if (Test-Path "$ENV:USERPROFILE\Downloads\SysInternals") {
        Remove-Item "$ENV:USERPROFILE\Downloads\SysInternals" -Force -Recurse;
      }

      $SysInternalsFolder = New-Item -Path "$ENV:USERPROFILE\Downloads\SysInternals" -ItemType Directory -Force;
      Invoke-WebRequest -UseBasicParsing -Uri "https://download.sysinternals.com/files/SysinternalsSuite.zip" -OutFile "$SysInternalsFolder\sysinternals.zip";
      Expand-Archive -Path "$SysInternalsFolder\sysinternals.zip" -Force -DestinationPath "$SysInternalsFolder";
      Set-Location -Path "$SysInternalsFolder\"

      #Permanently add folder to path but needs reboot
      $path = ";$(Get-Location)";
      $theCurrentPath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH).path
      $theUpdatedPath = $theCurrentPath + $path
      Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value $theUpdatedPath;

      #temp add this folder to path
      Set-Item -Path $Env:Path -Value ($Env:Path + ";$(Get-Location)");
      Set-Location -Path "$ENV:USERPROFILE\Desktop";
    }
    #Begin the process
    Start-Process -FilePath "psexec.exe" -ArgumentList "\\$Comp -u $($PSCreds.UserName) -p $($PSCreds.Password) -h -d winrm.cmd quickconfig -q";
    Write-Host "Enabling WINRM Quickconfig" -ForegroundColor Green
    Write-Host "Waiting for 60 Seconds......." -ForegroundColor Yellow
    Start-Sleep -Seconds 60 -Verbose
    Start-Process -FilePath "psexec.exe" -ArgumentList "\\$Comp -u $($PSCreds.UserName) -p $($PSCreds.Password) -h -d powershell.exe enable-psremoting -force";
    Write-Host "Enabling PSRemoting" -ForegroundColor Green
    Start-Process -FilePath "psexec.exe" -ArgumentList "\\$Comp -u $($PSCreds.UserName) -p $($PSCreds.Password) -h -d powershell.exe set-executionpolicy Bypass -force";
    Write-Host "Enabling Execution Policy" -ForegroundColor Green
    Test-WSMan -ComputerName $Comp
  }
}
