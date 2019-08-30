# HelperFunctions

This is a collection of Powershell functions that help me. Please Free to add/change anything.  
Below are the functions and an explanation on how they work.

## **Update-VcRedist**

This function will download and install any missing Microsoft Visual C++ Redistributable Packages.

Usage:

```Update-VcRedist -DownloadDirectory 'C:\Temp';```

This one is only to be run locally, and as an administrator.

## **Install-MySQL**

This function will download and install MySQL Server version 5.7.27.
Using the Update-VcRedist function to install pre-requisites.

Usage:

```Install-MySQL -dbdirectory 'C:\ProgramData\MySQL\MySQL Server 5.7' -tempdownloaddirectory "$ENV:USERPROFILE\Downloads";```

This function must be run locally as an administrator and does a few things to ensure we install MySQL Server correctly, they are:

1. Securely (kinda) grabs the database password you would like to use.

2. Makes sure the download location exists.

3. Uses **Update-VcRedist** to install any pre-requisites.

4. Make sure we are using TLS 1.2.

5. Download and install MySQL Server 5.7.27 enabling error logging and slow logging.

6. Add MySQL to PATH.

7. Add a few optimisations to the My.ini file. 

8. All done! It is recommended to reboot the server to ensure MySQL is install correctly

## Things ToDo

#### **Update-VcRedist**

* Make it better.
  
* Add the ability to do this update remotely and on more then one computer.

#### **Install-MySQL**

* Make it better
  
* Add the ability to remotely install and on more than one computer.

* Optimise the Optimisation (Too many Set-Content's)

* Allow user to choose any MySQL version
  