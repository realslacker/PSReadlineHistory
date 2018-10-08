# PSReadlineHistory
The PSReadline module can maintain a persistent command-line history. However, the command history is not accessible with Get-History. This module attempts to fill that gap, as well as provide some optimization for the file.

This module is available in the PSGallery, to install:

```powershell
PS> Install-Module -Name PSReadlineHistory
```

# Commands
PSReadlineHistory can read and format, invoke, and optimize your PSReadline command history file. This module contains the following commands:

## Optimize-PSReadlineHistory
The PSReadline module can maintain a persistent command-line history. However, there are no provisions for managing the file. When the file gets very large, performance starting PowerShell can be affected. This command will trim the history file to a specified length as well as removing any duplicate entries.

```powershell
PS> Optimize-PSReadlineHistory -MaximumCommandCount 500 -Passthru


    Directory: C:\Users\brooks\Nextcloud\Documents\WindowsPowerShell


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        10/8/2018   8:07 AM           6509 Command-History.txt

```

## Get-PSReadlineHistory
Get the PSReadline history in a similar fasion to Get-History.

```powershell
PS> Get-PSReadlineHistory -Count 5 -Unique

 Id CommandLine
 -- -----------
122 $csv | Export-Csv -NoTypeInformation -Path '.\MachinePolicies.csv'
123 Import-Module PSReadlineHistory
125 Optimize-PSReadlineHistory -MaximumCommandCount 500 -Passthru
126 Get-PSReadlineHistory -Count 5 -Unique

```

## Invoke-PSReadlineHistory
Invoke PSReadline history in a similar fasion to Invoke-History.

```powershell
PS> Invoke-PSReadlineHistory 125


    Directory: C:\Users\brooks\Nextcloud\Documents\WindowsPowerShell


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        10/8/2018   8:10 AM           6579 Command-History.txt

```
