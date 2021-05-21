﻿<#
SQL Undercover Catalogue Interrogation
Written by David Fowler, 28/08/2018
Update 0.2.0 - 28/01/2019
Update 0.2.1 - 14/02/2019
Update 0.3.0 - 27/08/2019
Update 0.4.0 - 23/12/2019
Update 0.5.0 - 09/06/2020

MIT License
------------

Copyright 2019 SQL Undercover

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files 
(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, 
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
#>

#configuration variables, change these to suit your setup
$ConfigServer = "<central server>"
$SQLUndercoverDatabase = "SQLUndercover"

$ScriptVersion = "0.5.0"

#import dbatools
#Import-Module dbatools
Clear-Host

####################     Get configuration parameters from catalogue.configPoSH   #######################################

Write-Host "=============================================================================" -ForegroundColor White -BackgroundColor Black
Write-Host "|                         .lkx;.        'lkx,                               |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                        .oNMMNk:.  .;lxXWMW0'                              |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                        :XMMMMMWKOOKWMMMMMMWd.                             |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                       .kWMMMMMMMMMMMMMMMMMMX:                             |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                       cXMMMMMMMMMMMMMMMMMMMWx.                            |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                      .kWMMMMMMMMMMMMMMMMMMMMX:                            |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                      ;KMMMMMMMMMMMMMMMMMMMMMWd.                           |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                      oWMMMMMMMMMMMMMMMMMMMMMMK,                           |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                     .OMMMMMMMMMMMMMMMMMMMMMMMNl                           |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                     .;codxkkOO00KKKKKK00OOkxoc'                           |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                               ..........                                  |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                                                 .                         |" -ForegroundColor White -BackgroundColor Black
Write-Host "|            ..,:loxk0Oxoc:,'..............',;:ldk0Okdoc;'..                |" -ForegroundColor White -BackgroundColor Black
Write-Host "|      .,:ldOKXNWMMMMMMMMMWWNNXKKKKKKKKKKXXNNWMMMMMMMMMMWNX0Odl:'.          |" -ForegroundColor White -BackgroundColor Black
Write-Host "|   .lkKNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNKkc.       |" -ForegroundColor White -BackgroundColor Black
Write-Host "|   'd0NWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWXOl.       |" -ForegroundColor White -BackgroundColor Black
Write-Host "|     .';coxO0XNWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWNNK0kdl:,.          |" -ForegroundColor White -BackgroundColor Black
Write-Host "|            ..',;:clodxkkO00KKKKXXXXXXXKKKK0OOkxddolc:,,'..                |" -ForegroundColor White -BackgroundColor Black
Write-Host "|          .:dxdolc'  .,,''''',''',,,,,''''''.'',,.  .coodxkxc.             |" -ForegroundColor White -BackgroundColor Black
Write-Host "|        'l0WMMMMMMK; ;0NXXKK000Od:,,cdkOOO00KKXNk.  cNMMMMMMWXxc.          |" -ForegroundColor White -BackgroundColor Black
Write-Host "|     .;xXWMMMMMMMMMK:.;kXWWMWWXd'   ..:ONWMWWNKd'  .xWMMMMMMMMMWXkc.       |" -ForegroundColor White -BackgroundColor Black
Write-Host "|   .cONMMMMMMMMMMMMMXl. .,:c:;.        .';cc;,.   .dNMMMMMMMMMMMMMWXk:.    |" -ForegroundColor White -BackgroundColor Black
Write-Host "|   .;clodkOKNWWMMMMMMNd.                       .;xXWMMMMMMMWNX0Okdolc;.    |" -ForegroundColor White -BackgroundColor Black
Write-Host "|           .',:ldk0NWMW0:                    .cONMMMMNKOxoc;'..            |" -ForegroundColor White -BackgroundColor Black       
Write-Host "|                 .:OWMMMNx'                .lKWMMMMWKo'.                   |" -ForegroundColor White -BackgroundColor Black           
Write-Host "|               .;xXWMMMMMWXo.            .c0WMMMMMMMWXOd:'.                |" -ForegroundColor White -BackgroundColor Black            
Write-Host "|              'xXWMMMMMMMMMWKo'         ,kWMMMMMMMMMWX0kd:.                |" -ForegroundColor White -BackgroundColor Black            
Write-Host "|              ..,cdOKNWMMMMMMMXd,.    .cKMMMMMMWN0xl;..                    |" -ForegroundColor White -BackgroundColor Black                
Write-Host "|                    .,cx0NWMMMMMNO; .,dNMMMMWKkl,.                         |" -ForegroundColor White -BackgroundColor Black                    
Write-Host "|                        .':dOXWMMXc.dXNMMMXkc.                             |" -ForegroundColor White -BackgroundColor Black                        
Write-Host "|                             .:oOo.lNMMWKo,                                |" -ForegroundColor White -BackgroundColor Black                          
Write-Host "|                                  '0MWXo.                                  |" -ForegroundColor White -BackgroundColor Black                           
Write-Host "|                                  cKkl,                                    |" -ForegroundColor White -BackgroundColor Black                            
Write-Host "|                                  ;c.                                      |" -ForegroundColor White -BackgroundColor Black                                                                      
Write-Host "=============================================================================" -ForegroundColor White -BackgroundColor Black
Write-Host "|                           Undercover Catalogue                            |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                              version 0.5.0                                |" -ForegroundColor White -BackgroundColor Black
Write-Host "|                          ©2020 sqlundercover.com                          |" -ForegroundColor White -BackgroundColor Black
Write-Host "=============================================================================" -ForegroundColor White -BackgroundColor Black
Write-Host "=============================================================================" -ForegroundColor White -BackgroundColor Black
Write-Host "getting configuration parameters..." -ForegroundColor Yellow

#$Config = Invoke-DbaQuery -SQLInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "SELECT ParameterName, ParameterValue FROM Catalogue.ConfigPoSH" -As DataSet

$ConfigConn = New-Object system.data.SqlClient.SqlConnection("Data Source=$ConfigServer;Initial Catalog=$SQLUndercoverDatabase; Integrated Security=SSPI")
$Config = New-Object System.Data.DataSet
$ConfigQuery = 'SELECT ParameterName, ParameterValue FROM Catalogue.ConfigPoSH'
$ConfigDataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter ($ConfigQuery, $ConfigConn)
$ConfigDataAdapter.Fill($Config)


$dbatoolsRequiredVersion = $Config.Tables[0].Select("ParameterName = 'DBAToolsRequirement'").ItemArray[1].ToString()
$CatalogueVersion = $Config.Tables[0].Select("ParameterName = 'CatalogueVersion'").ItemArray[1].ToString()
$AutoDiscoverInstances = $Config.Tables[0].Select("ParameterName = 'AutoDiscoverInstances'").ItemArray[1].ToString()
$AutoUpdate = $Config.Tables[0].Select("ParameterName = 'AutoUpdate'").ItemArray[1].ToString()
$AutoInstall= $Config.Tables[0].Select("ParameterName = 'AutoInstall'").ItemArray[1].ToString()
$InstallLocation= $Config.Tables[0].Select("ParameterName = 'InstallationScriptPath'").ItemArray[1].ToString()

####################     Display congif info    #########################################################################

Write-Host "Undercover Catalogue Version:" $CatalogueVersion -ForegroundColor Green
Write-Host "Central Configuration Server:" $ConfigServer -ForegroundColor Green
Write-Host "SQL Undercover Database:" $SQLUndercoverDatabase -ForegroundColor Green


####################     Check dbatools is installed and at supported version    ########################################

<#$module =Get-Module dbatools

If ($module.Version -lt $dbatoolsRequiredVersion) {Throw "Your either don't have dbatools installed or your installed module doesn't meet the required version.  Check out dbatools.io for full details."}
ELSE
{Write-Host "dbatools, installed version: "$module.Version ", required version: "$dbatoolsRequiredVersion -ForegroundColor Green}
#>
###################    auto discover SQL instances     ##################################################################

If ($AutoDiscoverInstances -eq "1")
{
    Write-Host "Auto Discover Instances: Enabled" -ForegroundColor Green
    Write-Host "Discovering SQL Instances..." -ForegroundColor Yellow

    $SQLServers = [System.Data.Sql.SqlDataSourceEnumerator]::Instance.GetDataSources()

    #for each instance discovered
    ForEach ($SQLServer IN $SQLServers.rows)
    {

    If ($SQLServer.ItemArray[1].ToString() -eq [String]::Empty) #if instance is a default instance
    {
        #create insert command where instance is a default instance
        $InsertCmd = "IF NOT EXISTS (SELECT 1 FROM Catalogue.ConfigInstances 
                        WHERE ServerName = '" + $SQLServer.ItemArray[0].ToString() + "')
                        INSERT INTO Catalogue.ConfigInstances(ServerName, Active) 
                        VALUES('" + $SQLServer.ItemArray[0].ToString() + "',0)"
    }
    else
    {
        #create insert command where instance is a named instance
        $InsertCmd = "IF NOT EXISTS (SELECT 1 FROM Catalogue.ConfigInstances 
                        WHERE ServerName = '" + $SQLServer.ItemArray[0].ToString() + "\" + $SQLServer.ItemArray[1].ToString() + "')
                        INSERT INTO Catalogue.ConfigInstances(ServerName, Active) 
                        VALUES('" + $SQLServer.ItemArray[0].ToString() + "\" + $SQLServer.ItemArray[1].ToString() + "',0)"
    }

    Invoke-Sqlcmd -ServerInstance $ConfigServer -Database $SQLUndercoverDatabase -Query $InsertCmd

    }
}
Else
{
Write-Host "Auto Discover Instances: Disabled" -ForegroundColor Yellow
}


####################  Auto Update  #####################################################################################


if ($AutoUpdate -eq 1)
{
    Write-Host "Auto Update: Enabled" -ForegroundColor Yellow

    $Manifest = Invoke-WebRequest "$($InstallLocation)Manifest.csv"
    $ManifestArray = $Manifest.Content.Split([Environment]::NewLine)

    #check for main version updates
    if ($ManifestArray[0].Split(",")[1] -ne $CatalogueVersion)
    {
        Write-Host "Updates are available" -ForegroundColor Yellow

        #get required updates from the manifest
        foreach ($Update in $ManifestArray)
        {
            $UpdateDetails = $Update.Split(",")
            if ($UpdateDetails[0] -eq "Update")
            {
                if ($UpdateDetails[1] -gt $CatalogueVersion) #if update is for a later version than currently installed then run it in
                {
                    Write-Host "Installing update $($UpdateDetails[1])" -ForegroundColor Yellow
                    $UpdateStmt = Invoke-WebRequest "$InstallLocation$($UpdateDetails[2])"

                    Invoke-Sqlcmd -ServerInstance $ConfigServer -Database $SQLUndercoverDatabase -Query $UpdateStmt 
                    Start-Sleep -s 10
                }
            }
        }
    }
    else
    {
        Write-Host "You're running on the most recent version" -ForegroundColor Green
    }
}
else
{
    Write-Host "Auto Update: Disabled" -ForegroundColor Yellow
}

#check minimum PoSH script version
if ($ManifestArray[1].Split(",")[1] -gt $ScriptVersion)
{
    Throw "You're running an incompatible version of the PowerShell script, this should be updated.  Please visit SQL Undercover for the latest version"
}
else
{
    Write-Host "You're running a compatible version of the PowerShell script" -ForegroundColor Green
}

######################################################################################################################




#Update Execution Audit
Write-Host "Updating Execution Audit" -ForegroundColor Yellow
#Invoke-DbaQuery -SQLInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "INSERT INTO Catalogue.ExecutionLog(ExecutionDate) VALUES(GETDATE())"
Invoke-Sqlcmd -ServerInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "INSERT INTO Catalogue.ExecutionLog(ExecutionDate) VALUES(GETDATE())"

####################    update catalogue     ##########################################################################


#get all instances
$Instances = New-Object System.Data.DataSet
$ConfigDataAdapter.SelectCommand = "SELECT [ServerName] FROM Catalogue.ConfigInstances WHERE Active = 1"
$ConfigDataAdapter.SelectCommand.Connection = $ConfigConn
$ConfigDataAdapter.Fill($Instances)

#$Instances = Invoke-DbaQuery -SQLInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "SELECT [ServerName] FROM Catalogue.ConfigInstances WHERE Active = 1" -As DataSet


#for every instance in the ConfigInstances table
ForEach ($instance in $Instances.Tables[0].Rows)
{
    Try
    {
        Write-Host "Interrogating Instance: "$instance.ItemArray[0].ToString() "..." -ForegroundColor Yellow

        #set up remote instance connection
        $RemoteConn = New-Object system.data.SqlClient.SqlConnection("Data Source=$($instance.ItemArray[0].ToString()); Integrated Security=SSPI")


        #get all active modules
        $Modules = New-Object System.Data.DataSet
        $ConfigDataAdapter.SelectCommand = "EXEC Catalogue.GetModuleDetails '$($instance.ItemArray[0].ToString())'"
        $ConfigDataAdapter.SelectCommand.Connection = $ConfigConn
        $ConfigDataAdapter.Fill($Modules)
        #$Modules = Invoke-DbaQuery -SQLInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "EXEC Catalogue.GetModuleDetails '$($instance.ItemArray[0].ToString())'" -As DataSet
       
        #for every active module in the ConfigModules table
        ForEach ($row in $Modules.Tables[0].Rows)
        {
            Write-Host "   Processing Module: "$row.ItemArray[0].ToString() "..." -ForegroundColor Yellow

            #load in module definitions
            if ($row.ItemArray[9] -eq 1) #if module definition online, attempt to get definitions from URL
            {
                try
                {
                    $GetModuleCode = Invoke-WebRequest $row.ItemArray[7];

                    #check for differences between git and local definitions
                    if ($($GetModuleCode -replace "`n|`r") -ne $($row.ItemArray[5].ToString() -replace "`n|`r"))
                    {
                        Write-Host "A difference has been detected between the online and local definitions" -ForegroundColor Red
                        if ($AutoUpdate -eq 0)
                        {
                            Write-Host "Autoupdate is disabled, you may need to manually update the module definition" -ForegroundColor Yellow
                        }
                        elseif ($AutoUpdate -eq 1)
                        {
                            Write-Host "Local definition will be automatically updated to match online definition" -ForegroundColor Yellow
                            Invoke-Sqlcmd -ServerInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "UPDATE [Catalogue].[ConfigModulesDefinitions] SET GetDefinition = '$($GetModuleCode  -replace "'", "''")' WHERE ModuleID = $($row.ItemArray[10].ToString())"
                            #Invoke-DbaQuery  -SQLInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "UPDATE [Catalogue].[ConfigModulesDefinitions] SET GetDefinition = '$($GetModuleCode  -replace "'", "''")' WHERE ModuleID = $($row.ItemArray[10].ToString())"
                            Write-Host "Module Definition Updated" -ForegroundColor Green
                        }
                    }
                }
                catch
                {
                    Write-Host "Failed to retrieve online 'Get' module definition, loading definition from database" -ForegroundColor Red
                    $GetModuleCode = $row.ItemArray[5].ToString()
                }

                try
                {
                    $UpdateModuleCode = Invoke-WebRequest $row.ItemArray[8];

                    #check for differences between git and local definitions
                    if ($($UpdateModuleCode -replace "`n|`r") -ne $($row.ItemArray[6].ToString() -replace "`n|`r"))
                    {
                        Write-Host "A difference has been detected between the online and local definitions" -ForegroundColor Red
                        if ($AutoUpdate -eq 0)
                        {
                            Write-Host "Autoupdate is disabled, you may need to manually update the module definition" -ForegroundColor Yellow
                        }
                        elseif ($AutoUpdate -eq 1)
                        {
                            Write-Host "Local definition will be automatically updated to match online definition" -ForegroundColor Yellow
                            #Invoke-DbaQuery  -SQLInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "UPDATE [Catalogue].[ConfigModulesDefinitions] SET UpdateDefinition = '$($UpdateModuleCode  -replace "'", "''")' WHERE ModuleID = $($row.ItemArray[10].ToString())"
                            Invoke-Sqlcmd -ServerInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "UPDATE [Catalogue].[ConfigModulesDefinitions] SET UpdateDefinition = '$($UpdateModuleCode  -replace "'", "''")' WHERE ModuleID = $($row.ItemArray[10].ToString())" 
                            Write-Host "Module Definition Updated" -ForegroundColor Green
                        }
                    }
                }
                catch
                {
                    Write-Host "Failed to retrieve online 'Update' module definition, loading definition from database" -ForegroundColor Red
                    $UpdateModuleCode = $row.ItemArray[6].ToString()
                }
            }
            else
            {
                #set execution variables
                $GetModuleCode = $row.ItemArray[5].ToString()
                $UpdateModuleCode = $row.ItemArray[6].ToString()
            }

            $StageTableName = $row.ItemArray[3].ToString()
            #process module
            #Run the get procedure against remote instance

            $ModuleData = New-Object System.Data.DataSet
            $ModuleQuery = $GetModuleCode
            $ModuleDataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter ($ModuleQuery, $RemoteConn)
            $ModuleDataAdapter.Fill($ModuleData)
            #$DataSet = Invoke-DbaQuery -SQLInstance $instance.ItemArray[0].ToString() -Query $GetModuleCode -As DataSet
            
            #insert data from get procedure into staging table on central server
            #Write-DbaDataTable -SqlInstance $ConfigServer -InputObject $DataSet.Tables[0] -Database $SQLUndercoverDatabase -Schema "Catalogue" -Table $StageTableName -Truncate -confirm:$false
            $ModuleBulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($ConfigConn)
            $ModuleBulkCopy.DestinationTableName = "Catalogue.$StageTableName"

            if ($ConfigConn.State -eq "Closed")
            {
                $ConfigConn.Open()
            }

            Invoke-Sqlcmd -ServerInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "TRUNCATE TABLE Catalogue.$StageTableName"
            $ModuleBulkCopy.WriteToServer($ModuleData.Tables[0])
            $ConfigConn.Close()

            #run the update procedure on the central server
            Invoke-Sqlcmd -ServerInstance $ConfigServer -Database $SQLUndercoverDatabase -Query $UpdateModuleCode

        }
    }
    catch
    {
        Write-Host "Interrogation encountered an error and could not continue." -ForegroundColor Red
        Write-Host $Error[0].Exception.Message
        #Write-Host $WarningMessage -ForegroundColor Red
        #if version mismatch
        If ($Error[0].Exception.Message -like "*The Catalogue version*") 
        #if auto update is enabled
        {
            Write-Host $Error[0].Exception.Message -ForegroundColor Red
            If ($AutoUpdate -eq 1)
                {Write-Host "***Auto-update enabled but is not available in this release, update the Undercover Catalogue manually on the remote host***" -ForegroundColor Yellow}
            Else
                {Write-Host "Auto-update Disabled, update the Undercover Catalogue manually on the remote host or enable auto-update" -ForegroundColor Yellow}
        }
        ElseIf ($WarningMessage -like "*Cannot open database*") 
                {
            Write-Host "Cannot access Catalogue, install Catalogue on remote host or allow access" -ForegroundColor Red
            If ($AutoInstall -eq 1)
                {Write-Host "***Auto-install enabled but is not available in this release, install the Undercover Catalogue manually on the remote host***" -ForegroundColor Yellow}
            Else
                {Write-Host "Auto-install Disabled, install the Undercover Catalogue manually on the remote host or enable auto-install" -ForegroundColor Yellow}
        }
        Else
        {
            Write-Host "An fatal error occured during interrogation" -ForegroundColor Red
        }
    }
}

#Update Execution Audit
Write-Host "Updating Execution Audit" -ForegroundColor Yellow
Invoke-Sqlcmd -ServerInstance $ConfigServer -Database $SQLUndercoverDatabase -Query "UPDATE Catalogue.ExecutionLog SET CompletedSuccessfully = 1 FROM Catalogue.ExecutionLog WHERE ID = (SELECT MAX(ID) FROM Catalogue.ExecutionLog)"


Write-Host "Interrogation Completed" -ForegroundColor Green