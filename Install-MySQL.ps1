function Update-VcRedist {
<#
.SYNOPSIS
This function will download and install any missing VC++ Distributables
.EXAMPLE
Update-VcRedist -DownloadDirectory "C:\temp";
#>
  [CmdletBinding()]
  param(
    [string][Parameter(mandatory = $false)] $DownloadDirectory = "$ENV:USERPROFILE\Downloads"
  )

  begin {
    ##we need to install a few things before we install any modules
    Install-PackageProvider -Name NuGet -Force;
    Install-Module -Name VcRedist -Force;
    Import-Module -Name VcRedist;
    $VcFolder = New-Item -Path "$DownloadDirectory\VcRedist" -ItemType Directory -Force;
  }

  process {
    # Install VC++ Redis, if it fails then the install needs to stop so we can fix it
    try {
      Get-VcList | Save-VcRedist -Path $VcFolder;
      $VcList = Get-VcList;
      Install-VcRedist -VcList $VcList -Path $VcFolder;
    } catch {
      Write-Host $_;
      Write-Error "There is a problem installing the required Visual Studio Redistributables" -ErrorAction Stop;
    }
  }

  end {
    #Sometimes VC++ 2013 is not installed via the above method - so ensuring it is installed
    Invoke-WebRequest -Uri "http://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/vcredist_x64.exe" -Verbose -UseBasicParsing -OutFile "$DownloadDirectory\vc2013.exe";
    Start-Process -FilePath "$DownloadDirectory\vc2013.exe" -ArgumentList "/install /passive";

    Write-Host "All Done installing requirements!";
  }
}

function Install-MySQL {
<#
.SYNOPSIS
This function will download, install and optimise Mysql 5.7.27
.EXAMPLE
Install-MySQL -dbdirectory 'C:\ProgramData\MySQL\MySQL Server 5.7' -tempdownloaddirectory 'c:\temp';
#>
  [CmdletBinding()]
  param(
    [string][Parameter(mandatory = $false)] $dbdirectory = 'C:\ProgramData\MySQL\MySQL Server 5.7',
    [string][Parameter(mandatory = $false)] $tempdownloaddirectory = "$ENV:USERPROFILE\Downloads"

  )

  begin {

    #Grab database password securely and convert to plain text when needed
    $dbpassword = Read-Host -AsSecureString -Prompt "Please enter database password" | ConvertFrom-SecureString;
    $securedbpassword = ConvertTo-SecureString $dbpassword;
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securedbpassword);
    $dbpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR);

    #Create Temporary directory to download files
    if (-not (Test-Path $tempdownloaddirectory)) { New-Item -ItemType Directory -Path $tempdownloaddirectory -Force };
    #Make sure server is not missing any VC++ Redists
    Update-VcRedist;
    #Make sure we are iusing the latest version of TLS
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
  }

  process {
    #Download and install MySQL
    Invoke-WebRequest -UseBasicParsing -Uri 'https://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-web-community-8.0.17.0.msi' -OutFile "$tempdownloaddirectory\mysqlinstaller.msi";
    Start-Process -FilePath "$tempdownloaddirectory\mysqlinstaller.msi" -Wait -ArgumentList '/quiet';
    Set-Location -Verbose -Path 'c:\program files (x86)\MySQL\mysql installer for windows\';
    cmd.exe /c "mysqlInstallerConsole.exe  community install server;5.7.27;x64:*:type=config;errorlogname=`"MySqlerrorlog.log`";openfirewall=`"true`";openfirewallforxprotocol=`"false`";passwd=`"$dbpassword`";port=`"3306`";serverid=`"1`";servertype=`"Server`";slowlog=`"true`";datadir=`"$dbdirectory`" -silent";
    #Make sure MySQL is added to Path (will need reboot)
    $path = ";C:\Program Files\MySQL\MySQL Server 5.7\bin;";
    $theCurrentPath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH).path;
    $theUpdatedPath = $theCurrentPath + $path;
    Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value $theUpdatedPath;
    $Env:path += ";C:\Program Files\MySQL\MySQL Server 5.7\bin;c:\php;";
  }

  end {
    #Optimise Mysql Database
    Stop-Service -Name "MySQL*" -Force;
    $megabytes = "M";
    $ram = [math]::Round((((Get-CimInstance -Class "cim_physicalmemory" | Measure-Object -Property Capacity -Sum).Sum) / 1MB));
    $innodbbufferpool = [math]::Round(($ram * .7));
    $innodblogfile = [math]::Round(($innodbbufferpool * .6));
    $newinnodbbufferpool = "$innodbbufferpool" + $megabytes;
    $newinnodblogfile = "$innodblogfile" + $megabytes;

    $corecount = ((Get-CimInstance -ClassName 'Win32_Processor' | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum);


    #continue with optimisations
    $findA = 'max_connections=(\d+).*';
    $replaceA = 'max_connections=300';
    $findB = 'thread_cache_size=(\d+).*';
    $replaceB = 'thread_cache_size=30';
    $findC = 'innodb_flush_log_at_trx_commit=(\d+).*';
    $replaceC = 'innodb_flush_log_at_trx_commit=0';
    $findD = 'innodb_buffer_pool_size=(\d+M).*';
    $replaceD = "innodb_buffer_pool_size=$newinnodbbufferpool";
    $findE = 'innodb_log_file_size=(\d+M).*';
    $replaceE = "innodb_log_file_size=$newinnodblogfile";
    $findF = 'sort_buffer_size=(\d+K).*';
    $replaceF = 'sort_buffer_size=1M';
    $findG = 'innodb_thread_concurrency=(\d+).*';
    $replaceG = "innodb_thread_concurrency=$corecount";
    $findH = 'innodb_buffer_pool_instances=(\d+).*';
    $replaceH = "innodb_buffer_pool_instances=$corecount";
    $findI = 'join_buffer_size=(\d+K).*';
    $replaceI = 'join_buffer_size=256M';
    $findJ = 'max_allowed_packet=(\d+M).*';
    $replaceJ = 'max_allowed_packet=512M';

    #Maketh the changeths
    (Get-Content -Path "$dbdirectory\my.ini" -Raw) -replace $findA,$replaceA | Set-Content -Path "$dbdirectory\my.ini";
    (Get-Content -Path "$dbdirectory\my.ini" -Raw) -replace $findB,$replaceB | Set-Content -Path "$dbdirectory\my.ini";
    (Get-Content -Path "$dbdirectory\my.ini" -Raw) -replace $findC,$replaceC | Set-Content -Path "$dbdirectory\my.ini";
    (Get-Content -Path "$dbdirectory\my.ini" -Raw) -replace $findD,$replaceD | Set-Content -Path "$dbdirectory\my.ini";
    (Get-Content -Path "$dbdirectory\my.ini" -Raw) -replace $findE,$replaceE | Set-Content -Path "$dbdirectory\my.ini";
    (Get-Content -Path "$dbdirectory\my.ini" -Raw) -replace $findF,$replaceF | Set-Content -Path "$dbdirectory\my.ini";
    (Get-Content -Path "$dbdirectory\my.ini" -Raw) -replace $findG,$replaceG | Set-Content -Path "$dbdirectory\my.ini";
    (Get-Content -Path "$dbdirectory\my.ini" -Raw) -replace $findH,$replaceH | Set-Content -Path "$dbdirectory\my.ini";
    (Get-Content -Path "$dbdirectory\my.ini" -Raw) -replace $findI,$replaceI | Set-Content -Path "$dbdirectory\my.ini";
    (Get-Content -Path "$dbdirectory\my.ini" -Raw) -replace $findJ,$replaceJ | Set-Content -Path "$dbdirectory\my.ini";

    #Remove in memory log files and restart mysql
    Remove-Item -Path "$dbdirectory\Data\ib_logfile0";
    Remove-Item -Path "$dbdirectory\Data\ib_logfile1";
    Start-Service -Name "MySQL*";

    Write-Host "All done, please reboot server to complete install" -ForegroundColor Yellow;

  }
}
