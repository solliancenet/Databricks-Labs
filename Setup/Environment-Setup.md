# Environment Setup

This article describes the steps required to setup the environment in order to conduct the labs. 


## 1. Deploy the Environment: HDInsight Clusters, Attached Storage Accounts, Sample Data
An ARM template and script is provided to aid in provisioning the clusters for attendees to use. Follow these steps to deploy your cluster:

1. Navigate to the Setup\Scripts folder. 
2. Open azuredeploy.all.parameters.json and provide the settings requested. At minimum provide a unique name for the cluster. Enter 'Yes' or 'No' for `provisionSpark`, `provisionLLAP`, `provisionKafka', and `provisionSecure`. This will specify whether to provision a Spark, Interactive (LLAP), Kafka, or Domain-Joined (Secure) set of clusters.
3. Save the file.
4. Open PowerShell and run the following command to login to your Azure account:

    ```
    Login-AzureRmAccount
    ```

4. Run the following command to provision the cluster (be sure to provide a unique cluster name):

    ```
    .\Deploy-LabEnvironment.ps1 -subscriptionId "[subscriptionID]" -resourceGroupName "[newResourceGroupName]" -clusterName "[clusterNamePrefix]" -clusterCount 1 -resourceGroupLocation "[location]"
    ```

    For example, the following creates the environment in the East US location, where 2 clusters are created sharing one storage account (each will have its own container in that storage account):

    ```
    .\Deploy-LabEnvironment.ps1 -subscriptionId "40fc406c-c745-44f0-be2d-63b1c860cde0" -resourceGroupName "HDILabs-01" -clusterName "hdilabs1149" -clusterCount 2
    ```

    **NOTE:** You may need to relax your PowerShell execution policy to execute this script. To do so, before running the above first run:
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted

    ```
    NOTE: Cluster Creation uses these as the defaults:
    - cluster name : [user supplied] 
    - subscription: [user supplied]  
    - resource group: [user supplied] 
    - cluster type: Spark 2.1 on Linux HDI 3.6
    - cluster login username: admin
    - cluster login password: Abc!1234567890
    - ssh username: sshuser
    - use same password as cluster login: checked
    - location: [eastus]

    - primary storage type: Azure Storage
    - selection method: access key
    - storage account name: [same value as cluster name]
    - storage account key: [key]
    - default container: [clusername + ##]

    - number of worker nodes: 2
    - worker node size: D12 v2
    - head node size: D12 v2
    (will use 16 cores)
    ```

## 2. Verify the Sample Data Copy
For each cluster, the script takes care of creating a new storage account, creating the default container in it and copying the sample data into that container. After the copy has completed, your clusters will contain a copy of the retaildata files underneath the path /retaildata in the default storage container for the cluster. 

The retaildata source files are currently available at the following location, accessed with a SAS token

**account name**: retaildatasamples

**container**: data

**path**: retaildata  

**SAS Key**: ?sv=2017-04-17&ss=b&srt=co&sp=rl&se=2019-12-31T18:29:33Z&st=2017-09-18T10:29:33Z&spr=https&sig=bw1EJflDFx9NuvLRdBGql8RU%2FC9oz92Dz8Xs76cftJM%3D

Verify the copy has completed by navigating to the destination container using the Azure Portal. In the container list, select the ellipses and then Container properties. If your ouput matches the following, all of the files have been copied over:

    Container Size
    * Blob Count: 3202
    * Size: 12.02 GiB
