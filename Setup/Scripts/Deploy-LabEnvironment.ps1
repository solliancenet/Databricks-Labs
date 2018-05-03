Param(
    [string] [Parameter(Mandatory=$true)] $subscriptionId,
    [string] [Parameter(Mandatory=$true)] $resourceGroupName,
    [string] [Parameter(Mandatory=$true)] $clusterName,
    [string] [Parameter(Mandatory=$true)] $clusterCount,
    [string] $resourceGroupLocation = 'eastus'
)

#$subscriptionId = 'e123f1b3-d19b-4cfa-98e9-bc9be62717bc'
#$resourceGroupName = 'HDInsightLabsEnvironmentZ'
#$resourceGroupLocation = 'westus2'
#$clusterName = 'hdilabsz1'
#$numInstances = 2

$destContainerName = "hdi-labs"
$sourceFolder = Get-Location
$clusterInstanceName = $clusterName
$resourceGroupInstanceName = $resourceGroupName


# Get-AzureRmSubscription

Login-AzureRmAccount 

$sub = Select-AzureRmSubscription -SubscriptionId $subscriptionId
Write-Host("Deploying instances with prefix " + $clusterInstanceName + " in Resource Group " + $resourceGroupInstanceName + " in subscription " + $sub.Subscription.SubscriptionName + " (" + $sub.Subscription.SubscriptionId + ")")
Set-Location $sourceFolder
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupName $resourceGroupInstanceName `
                                -ResourceGroupLocation $resourceGroupLocation `
                                -TemplateFile 'azuredeploy.all.json' `
                                -TemplateParametersFile 'azuredeploy.all.parameters.json' `
                                -ClusterName $clusterInstanceName `
                                -ClusterCount $clusterCount
$storageAccountName = $clusterInstanceName
Select-AzureRmSubscription -SubscriptionId $subscriptionId
#Set-AzureRmCurrentStorageAccount -ResourceGroupName $resourceGroupInstanceName -Name $storageAccountName
#New-AzureStorageContainer -Name $destContainerName -Permission Off
$storageKey = (Get-AzureRmStorageAccountKey -Name $storageAccountName -ResourceGroupName $resourceGroupInstanceName).Value[0]

Write-Host("Creating " + $clusterCount + " storage containers. This can take a while.")
$StorageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey
For($i = 0; $i -lt $clusterCount; $i++){
    $destContainerName = $clusterName + $i
	### Create a Blob Container in the Storage Account
	New-AzureStorageContainer -Context $StorageContext -Name $destContainerName;
	Write-Host("Copy the following to your Databricks cluster init configuration (blob files will be located in a container named '" + $destContainerName + "'):")
	Write-Host("spark.hadoop.fs.azure.account.key." + $storageAccountName + ".blob.core.windows.net " + $storageKey)
}
Write-Host("Storage container creation complete, and deployment operations are finished. If there are no errors, you are free to begin using the workspace and clusters.") -ForegroundColor Green