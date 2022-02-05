<#
    .SYNOPSIS
    New-SSISProxyUser is a PowerShell script that creates a new local user account and adds that account to the Administrators group.
    .DESCRIPTION
    New-SSISProxyUser is a PowerShell script that creates a new local administrator account.
    This new account is then used to create both a SQL credential and proxy for SSIS agent jobs.
#>

# Create new local user account
$user = "SSIS_Proxy"
$pass = "uVI^Vj[fbVvV9m2QHjb"

try{
    # Using the .NET WindowsIdentity class to check for elevation
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)

    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) { 
        # Create the user
        $Computer = [ADSI]"WinNT://$Env:COMPUTERNAME,Computer"
        $LocalAdmin = $Computer.Create("User", $user)
        $LocalAdmin.SetPassword($pass)
        $LocalAdmin.UserFlags = 64 + 65536 # ADS_UF_PASSWD_CANT_CHANGE + ADS_UF_DONT_EXPIRE_PASSWD
        $LocalAdmin.SetInfo()
                
        # Add user to the administrators group
        $group = [ADSI]"WinNT://$Env:COMPUTERNAME/Administrators,group"
        $group.Add("WinNT://"+$Env:COMPUTERNAME+"/"+$user)
    }
    else { 
        Write-Warning "Please run as administrator."
    }
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -BackgroundColor Red
}

# Creat SQL credential and proxy
Import-Module SqlPS
$sql_instance_name = 'localhost'
$db_name = 'master'
$identity = $env:computername + "\" + $user
$query = "
            CREATE CREDENTIAL [$user] WITH IDENTITY = N'$identity', SECRET = N'$pass';
            EXEC msdb.dbo.sp_add_proxy @proxy_name = N'$user', @credential_name = N'$user', @enabled = 1;
            EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name = N'$user', @subsystem_id = 11;
"

Invoke-Sqlcmd -Database $db_name -Query $query -serverinstance $sql_instance_name
