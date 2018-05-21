# Environment Setup

This article describes the steps required to setup the environment in order to conduct the labs.

## 1. Deploy the Environment: Databricks Workspace, Azure Data Factory v2, Attached Storage Accounts, and Sample Data

An ARM template and script is provided to aid in provisioning the clusters for attendees to use. Follow these steps to deploy your cluster:

1.  Open PowerShell and run the following command to login to your Azure account:

    ```PowerShell
    Login-AzureRmAccount
    ```

1.  If you have more than one Azure subscription, execute the following to view your list of available subscriptions:

    ```PowerShell
    Get-AzureRmSubscription
    ```

1.  Execute the following to set the subscription to the appropriate one, if needed:

    ```PowerShell
    Select-AzureRmSubscription -SubscriptionName "<NAME>"
    ```

1.  Confirm your default environment:

    ```PowerShell
    (Get-AzureRmContext).Subscription
    ```

1.  In PowerShell, navigate to the Setup\Scripts folder.
1.  Next, you will execute the `.\Deploy-LabEnvironment.ps1` PowerShell script, passing in the following parameters:

    1.  subscriptionId (Mandatory)
    2.  resourceGroupName (Mandatory)
    3.  workspaceName (Mandatory)
    4.  workspaceCount (Mandatory)
    5.  resourceGroupLocation (Default value = 'eastus')
    6.  skipLab1 (optional switch)

1.  Run the following command to provision the workspace (be sure to provide a unique workspace name):

    ```PowerShell
    .\Deploy-LabEnvironment.ps1 -subscriptionId "[subscriptionID]" -resourceGroupName "[newResourceGroupName]" -workspaceName "[workspaceNamePrefix]" -workspaceCount 1 -resourceGroupLocation "[location]"
    ```

    For example, the following creates the environment in the East US location, where 2 clusters are created sharing one storage account (each will have its own container in that storage account):

    ```PowerShell
    .\Deploy-LabEnvironment.ps1 -subscriptionId "40fc406c-c745-44f0-be2d-63b1c860cde0" -resourceGroupName "DatabricksLabs-01" -workspaceName "databrickslabs1149" -workspaceCount 2
    ```

    **NOTE:** You may need to relax your PowerShell execution policy to execute this script. To do so, before running the above first run:
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted

    **NOTE:** If you are skipping Lab 1, you will need to provide the `-skipLab1` switch to the PowerShell command. This will copy the lab files to the default Azure Storage account so you can successfully complete the other labs. This is because Azure Data Factory is used to copy the files as part of Lab 1. When you specify `-skipLab1`, Azure Data Factory is not provisioned.
    Example:

    ```PowerShell
    .\Deploy-LabEnvironment.ps1 -subscriptionId "[subscriptionID]" -resourceGroupName "[newResourceGroupName]" -workspaceName "[workspaceNamePrefix]" -workspaceCount 1 -resourceGroupLocation "[location]" -skipLab1
    ```

    ```md
    NOTE: Environment Creation uses these as the defaults:

    * workspace name : [user supplied]
    * subscription: [user supplied]
    * resource group: [user supplied]
    * pricing tier (Azure Databricks): premium
    * location: [eastus]

    * primary storage type: Azure Storage
    * selection method: access key
    * storage account name: [same value as cluster name]
    * storage account key: [key]
    * default container: [workspaceName + ##]
    ```

## 2. Create and Run a new Azure Databricks Cluster

1.  Using the Azure Portal, navigate to your Azure Databricks workspace.
1.  Within the Overview blade, select **Launch Workspace**.
1.  Once logged in to the Azure Databricks workspace, select **Clusters** on the left-hand menu.
1.  Select **+ Create Cluster**.
1.  Set the following in the cluster creation form:
    1.  Cluster Type: Standard
    1.  Cluster Name: Provide a unique name, such as Lab
    1.  Databricks Runtime Version: Select 4.0 or greater (non-beta versions)
    1.  Python Version: 3
    1.  Driver Type: Default value
    1.  Worker Type: Default value (same for Min Workers and Max Workers)
    1.  Auto Termination: Check the box and set to 120 minutes of inactivity
1.  **Important:** Edit the Spark Config by entering the connection information for your Azure Storage account. This will allow your cluster to access the lab files. You will find the init configuration value at the bottom of the PowerShell output after executing the `Deploy-LabEnvironment.ps1` script. The string should look similar to the following: `spark.hadoop.fs.azure.account.key.mydatabrickslab.blob.core.windows.net 8/jR7FXwkajLPObf8OOETzuiJxaIiI6B6z0m8euneUe0DgX/TnGHoywMw25kYdyTk/ap0eZ2PsQhXfE/E5d2Kg==`, where `mydatabrickslab` is your Azure Storage account name (matches the `workspaceName` value), and `8/jR7FXwkajLPObf8OOETzuiJxaIiI6B6z0m8euneUe0DgX/TnGHoywMw25kYdyTk/ap0eZ2PsQhXfE/E5d2Kg==` is your storage access key.
1.  Select **Create Cluster**

**Note:** Your lab files will be copied to a container created in the storage account with the following naming convention: {STORAGE-ACCOUNT-NAME}+{WORKSPACE-COUNT}. The default {WORKSPACE-COUNT} value is 0 when you specify 1 for the `workspaceCount` parameter. If creating multiple workspaces for a classroom environment, be sure to assign a number to each student and have them use that corresponding number that is appended to the end of their Azure Databricks workspace name, HDInsight Kafka cluster name, and the end of the container name within the lab's Azure Storage account.

## 3. Verify the Sample Data Copy

**Note:** This section only applies if you are skipping Lab 1 (using the `-skipLab1` switch)

For each Azure Databricks workspace, the script takes care of creating a new storage account, creating the default container in it and copying the sample data into that container. After the copy has completed, your workspaces will have access to a copy of the retaildata files underneath the path /retaildata in the storage container created for the workspace.

The retaildata source files are currently available at the following location, accessed with a SAS token.

**account name**: retaildatasamples

**container**: data

**path**: retaildata

**SAS Key**: ?sv=2017-04-17&ss=b&srt=co&sp=rl&se=2019-12-31T18:29:33Z&st=2017-09-18T10:29:33Z&spr=https&sig=bw1EJflDFx9NuvLRdBGql8RU%2FC9oz92Dz8Xs76cftJM%3D

Verify the copy has completed by navigating to the destination container using the Azure Portal. In the container list, select the ellipses and then Container properties. If your output matches the following, all of the files have been copied over:

    Container Size
    * Blob Count: 3202
    * Size: 12.02 GiB
