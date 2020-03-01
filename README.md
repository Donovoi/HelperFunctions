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

#### **format-australian-addresses.sql**
  
  This is a set of User Defined Functions in MySQL that I created recently for a client.

  The usage is simply `Select **FUNCTION_NAME(COLUMN_NAME)** FROM DATABASENAME;`

  The first function **CAP_FIRST** is to be used as a wrapper while using **FORMAT_ADDRESS** i.e `**CAP_FIRST(FORMAT_ADDRESS(COLUMN_NAME))**`.

**CAP_FIRST** will capitalize the first letter of every word. Handy for time where you have street names, and suburbs that don't need to be ALL CAPS. It will make everything lowercase first so be sure that you just want the first letter of the words in CAPS.

The second function **FORMAT_ADDRESS** will format the address based on the street name. First we will check if there are any spaces before a comma, and remove that space. Then we will go and replace street names with their 2-3 letter acronym according to **AS4590 Interchange of client information** specifications.

The third function **FORMAT_NT_POSTCODES** will look for any postcodes that are 3 digits and add a zero to the end. Excel does a great job of removing leading zeros so this helps get rid of that issue. Postcodes need to be in a separate column by themselves for this to work.

The last function **FORMAT_PO_BOXES** is a unique function that probably wont see much use outside of how I used it. First it needs to have a column that has full address so something similar to **PO BOX 123 MELBOURNE VIC 3000**.
The function will make sure there is a comma after the number i.e "123," and not "123". It will do this for **PO Box**, **Locked Bag**, **Private Mail Bag**, **Private Bag**, **GPO Box** addresses.

These Functions need MySQL server version 8 and above.

#### **format-australian-numbers.sql**

  The usage is simply `Select **FUNCTION_NAME(COLUMN_NAME)** FROM DATABASENAME;`

This document has just one function **FORMAT_PHONE_NUMBERS** that takes two inputs. The first input is a column that contains phone numbers. They can be mobile, landline, or 1300 numbers (haven't done 1800 numbers yet but should be easy to do).

The second input is a column that contains a state for each of these numbers i.e "VIC", "QLD", "TAS" etc...

The function will first remove any spaces from the data. Then it will look for numbers that are only eight digits long. Then it will prepend the correct area code to the landline number. So if it was an eight digit landline number and the state was "VIC" then we would prepend "03".

Once we've done that we will then format the landline numbers like so "00 0000 0000" and the 1300 numbers like so "1300 000 000".

I'm a MySQL newbie so any feedback or pull requests are much appreciated!
