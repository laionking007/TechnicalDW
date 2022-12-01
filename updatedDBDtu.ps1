param(
    [Parameter(Mandatory=$True,HelpMessage="Azure connections Azure Pipeline, AzureRunAsConnection & Service Principal  ")][ValidateSet('AP','RaA','SPC')][string]$azureCon,
    [Parameter(HelpMessage="Only if azureCon selected SPC. Provide the Application id")][SecureString]$ApplicationId,
    [Parameter(HelpMessage="Only if azureCon selected SPC. Provide the service principal secret")][SecureString]$SecuredPassword,
    [Parameter(HelpMessage="Only if azureCon selected SPC. Provide the Tenand Id ")][SecureString]$TenantId,
    [Parameter(Mandatory=$True,HelpMessage="DTU type to Update")][ValidateSet('sqlDB','sqlEP')][string]$sqlDtuType,
    [Parameter(Mandatory=$True,HelpMessage="Resource group name for the type that is been selected sqlDtuType")][string]$rg ,
    [Parameter(Mandatory=$True,HelpMessage="Provide the Sql server name")][string]$sqlServeName,
    [Parameter(HelpMessage="Only if sqlDB selected sqlDtuType. Provide the Sql database name")][string]$sqlDbName,
    [Parameter(HelpMessage="Only if sqlDB selected sqlDtuType. Provide the new Plan")][ValidateSet('Basic', 'Standard', 'Premium')][string]$sqlPlan,
    [Parameter(HelpMessage="Only if sqlDB selected sqlDtuType. Provide the new Tier")][ValidateSet('Basic', 'S0', 'S1', 'S2', 'S3', 'P1', 'P2', 'P4', 'P6', 'P11', 'P15')][string]$sqlTier,
    [Parameter(HelpMessage="Only if sqlEP selected sqlDtuType. Provide the Elastic pool name")][string]$epName,
    [Parameter(HelpMessage="Only if sqlEP selected sqlDtuType")][string]$epDtu,
    [Parameter(HelpMessage="Only if sqlEP selected sqlDtuType")][string]$epDatabaseDtuMaxEP,
    [Parameter(HelpMessage="Only if sqlEP selected sqlDtuType")][string]$epDatabaseDtuMinEP

)


if ($azureCon -eq 'RaA' ){
    try
    {
        $connectionName = "AzureRunAsConnection"
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }

}

if ($azureCon -eq 'SPC' ){

    try
    {
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecuredPassword
        Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
    }
    catch {
        
            Write-Error -Message $_.Exception
            throw $_.Exception
    }
    
}



if ($sqlDtuType -eq 'sqlDB')
{
    # Get the database object
    $sqlDB = Get-AzureRmSqlDatabase -ResourceGroupName $rg -ServerName $sqlServeName -DatabaseName $sqlDbName

    # Check current DG Edition and TIer
    if ($sqlDB.Edition -eq $sqlPlan -And $sqlDB.CurrentServiceObjectiveName -eq $sqlTier)
    {
        Write-Output "Already Database Server $($sqlServeName)\$($sqlDbName) is in required tier : $($sqlPlan):$($sqlTier)" 
    }
    else
    {
        Write-Output "Updating Database Server $($sqlServeName)\$($sqlDbName) to Edition : $($sqlPlan), tier: $($sqlTier)" 
        $sqlDB | Set-AzureRmSqlDatabase -Edition $sqlPlan -RequestedServiceObjectiveName $sqlTier | out-null
    }

    $sqlDB = Get-AzureRmSqlDatabase -ResourceGroupName $rg -ServerName $sqlServeName -DatabaseName $sqlDbName
    Write-Output "Final DB status: $($sqlDB.Status), edition: $($sqlDB.Edition), tier: $($sqlDB.CurrentServiceObjectiveName)" 
}
if ($sqlDtuType -eq 'sqlEP')
{
    Set-AzSqlElasticPool -ResourceGroupName $rg -ServerName $sqlServeName -ElasticPoolName $epName -Dtu $epDtu -DatabaseDtuMax $epDatabaseDtuMaxEP -DatabaseDtuMin $epDatabaseDtuMinEP
}
