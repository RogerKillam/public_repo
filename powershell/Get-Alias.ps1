
<#
    .SYNOPSIS
    Get-Alias is a PowerShell function that retrieves a user's Active Directory properties.
    .DESCRIPTION
    Get-Alias is a PowerShell function that retrieves a user's Active Directory name, alias, account creation date, assigned office, and password property details.
    There is one parameter: -Alias [Required] Specifies the target alias or aliases.
    .INPUTS
    You can pipe objects to Get-Alias.
    .OUTPUTS
    System.String.
    .EXAMPLE
    Get-Alias -Alias alias01, alias02, alias03
    .EXAMPLE
    Get-Content Get-Content C:\Data\aliases.txt | Get-Alias
    .NOTES
    Import-Module ActiveDirectory requires Remote Server Administration Tools (RSAT) be installed on the administrative client workstation.
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/import-module?view=powershell-7
    Get-ADUser
    https://docs.microsoft.com/en-us/powershell/module/activedirectory/get-aduser?view=winserver2012-ps
#>
function Get-Alias {
    param (
        [cmdletbinding(DefaultParameterSetName = "Alias")]
        [parameter (Mandatory = $true, position = 0, ValueFromPipeline = $true)]
        [String[]]
        $Alias
    )
    begin {
        Write-Verbose "Starting $($MyInvocation.Mycommand) `n"
        Import-Module ActiveDirectory
    }
    process {
        foreach ($i in $Alias) {
            Write-Verbose "<< Alias $i >>"
            Get-ADUser $i -Properties DisplayName, SamAccountName, created, physicalDeliveryOfficeName, PasswordLastSet, PasswordExpired | 
            Format-List @{L = "Name"; E = { $_.DisplayName } } `
                , @{L = "Alias"; E = { $_.SamAccountName } } `
                , @{L = "Created"; E = { $_.created } } `
                , @{L = "Office"; E = { $_.physicalDeliveryOfficeName } } `
                , @{L = "Password Last Set"; E = { $_.PasswordLastSet } } `
                , @{L = "Password Expired"; E = { $_.PasswordExpired } }
        }
    }
    end {
        Write-Verbose "Ending $($MyInvocation.Mycommand) `n"
    }
}
