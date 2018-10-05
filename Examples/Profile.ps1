# import PSReadline and PSReadlineHistory
Import-Module PSReadline, PSReadlineHistory

# configure PSReadline history file
Set-PSReadlineOption -HistorySaveStyle SaveIncrementally -HistoryNoDuplicates -HistorySavePath "$([environment]::GetFolderPath('Personal'))\WindowsPowerShell\Command-History.txt"

# create popup command history search using Get-PSReadlineHistory
Set-PSReadlineKeyHandler -Key F7 -BriefDescription "PSReadlineHistoryPopup" -LongDescription "Popup PSReadline history command selector" -ScriptBlock {
    
    # get the current content of the input buffer
    $HistorySearchPattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $HistorySearchPattern, [ref] $null)
    $MatchSplat = @{}
    if ( $HistorySearchPattern ) {
        $MatchSplat.Match = $HistorySearchPattern
    }
    
    # get the PSReadline command history
    $HistoryCommand = Get-PSReadlineHistory @MatchSplat | Sort-Object Id -Descending | Out-GridView -Title History -PassThru | Select-Object -ExpandProperty CommandLine
    if ( $HistoryCommand ) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($HistoryCommand)
    }

}

# add aliases for PSReadlineHistory functions
New-Alias -Name hh   -Value Get-PSReadlineHistory
New-Alias -Name ihhy -Value Invoke-PSReadlineHistory
