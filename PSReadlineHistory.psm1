<#
.SYNOPSIS

    Optimize the PSReadline history file

.DESCRIPTION

    The PSReadline module can maintain a persistent command-line history. However,
    there are no provisions for managing the file. When the file gets very large,
    performance starting PowerShell can be affected. This command will trim the
    history file to a specified length as well as removing any duplicate entries.

.PARAMETER MaximumLineCount

    Set the maximum number of lines to store in the history file. Defaults to the value of $MaximumHistoryCount.

.PARAMETER TrimDuplicates

    Removes duplicate lines. The default is to trim duplicates.

.PARAMETER PassThru

    By default this command does not write anything to the pipeline. Use -Passthru
    to get the updated history file.

.EXAMPLE
    
    PS> Optimize-PSReadelineHistory
        
    Trim the PSReadlineHistory file to default maximum number of lines.

.EXAMPLE

    PS> Optimize-PSReadelineHistory -MaximumCommandCount 500 -PassThru

    Trim the PSReadlineHistory file to 500 lines and display the file listing.

.LINK

    Get-PSReadlineOption

.LINK

    Set-PSReadlineOption

.LINK

    Get-PSReadlineHistory

.LINK

    Invoke-PSReadlineHistory

#>
function Optimize-PSReadlineHistory {
    
    param(

        [int]
        $MaximumCommandCount = $MaximumHistoryCount,

        [bool]
        $TrimDuplicates = $true,

        [switch]
        $Passthru

    )

    process {

        # remove duplicates ?
        $Unique = @{}
        if ( $TrimDuplicates ) { $Unique.Unique = $true }

        # get command history from PSReadLine
        $CommandHistory = Get-PSReadlineHistory -Count $MaximumCommandCount @Unique | Select-Object -ExpandProperty CommandLine

        # save the updates
        $CommandHistory -replace "`n", "```r`n" -join "`r`n" | Set-Content -Path (Get-PSReadlineOption).HistorySavePath

        if ($Passthru) {

            Get-Item -Path (Get-PSReadlineOption).HistorySavePath

        }

    }

}


<#
.SYNOPSIS

    Get the PSReadline history in a similar fasion to Get-History.

.DESCRIPTION

    The PSReadline module can maintain a persistent command-line history. However,
    there is no method for fetching the history with Get-History. This cmdlet emulates
    Get-History for the PSReadline history.

.PARAMETER Match

    Returns results that match a string.

.PARAMETER Id

    Returns a specific command history entry or entries.

.PARAMETER Count

    Returns the last [Count] command history entries.

.PARAMETER Unique

    Returns the only unique command history entries.

.EXAMPLE
    
    PS> Get-PSReadelineHistory
        
    Returns all PSReadline command history entries.

.EXAMPLE

    PS> Get-PSReadelineHistory -Count 5 -Unique

    Returns the last 5 unique command history entries.

.LINK

    Get-PSReadlineOption

.LINK

    Set-PSReadlineOption

.LINK

    Get-PSReadlineHistory

.LINK

    Invoke-PSReadlineHistory

#>
function Get-PSReadlineHistory {

    param(

        [Parameter(Position=0)]
        [string]
        $Match,

        [long[]]
        $Id,
    
        [int]
        $Count,

        [switch]
        $Unique
    
    )

    begin {

        $Merging = $false
        $Buffer  = ''
        $Index   = 1
    
        # get the PSReadline command history
        $CommandHistory = foreach ( $CommandLine in [System.IO.File]::ReadLines((Get-PSReadlineOption).HistorySavePath) ) {
            
            # if the line ends with a double backtick we merge with the next line
            if ( $CommandLine.EndsWith('``') ) {
                $Buffer += $CommandLine.Replace('``', '')
                $Merging = $true
                continue
            }

            # if the line ends with a single backtick we merge with the next line, but insert newlines
            if ( $CommandLine.EndsWith('`') ) {
                $Buffer += $CommandLine.Replace('`', "`n")
                $Merging = $true
                continue
            }

            # if we are merging, but current line doesn't have a backtick we output
            if ( $Merging ) {

                $CommandLine = $Buffer + $CommandLine
                $Merging = $false
                $Buffer = ''
        
            }

            # output
            New-Object -TypeName PSObject -Property @{ Id = $Index; CommandLine = $CommandLine }

            $Index++
            
        }

    }

    process {

        if ( $Match )  { $CommandHistory = $CommandHistory | Where-Object { $_.CommandLine -match [regex]::Escape($Match) } }
    
        if ( $Id )     { $CommandHistory = $CommandHistory | Where-Object { $_.Id -in $Id } }

        if ( $Unique ) { $CommandHistory = $CommandHistory | Sort-Object -Unique CommandLine | Sort-Object Id }

        if ( $Count )  { $CommandHistory = $CommandHistory | Select-Object -Last $Count }

        $CommandHistory

    }

}


<#
.SYNOPSIS

    Invoke PSReadline history in a similar fasion to Invoke-History.

.DESCRIPTION

    The PSReadline module can maintain a persistent command-line history. However,
    there is no method for invoking the history with Invoke-History. This cmdlet
    emulates Invoke-History for the PSReadline history.

.PARAMETER Id

    Runs a specific command history entry or entries.

.EXAMPLE
    
    PS> Invoke-PSReadelineHistory 5
        
    Runs the PSReadline history command with Id = 5.

.LINK

    Get-PSReadlineOption

.LINK

    Set-PSReadlineOption

.LINK

    Get-PSReadlineHistory

.LINK

    Invoke-PSReadlineHistory

#>
function Invoke-PSReadlineHistory {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
    
        [Parameter(Position=0, Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [long[]]
        $Id

    )

    process {

        Get-PSReadlineHistory -Id $Id | ForEach-Object {
        
            if ($PSCmdlet.ShouldProcess($_.CommandLine)) {
            
                &([scriptblock]::Create($_.CommandLine))

            }
    
        }

    }

}
