<#
.NOTES
Author: Michael Allen
Created: 08-27-2025
Changes:

.SYNOPSIS
This script queries all deployents in AKS and displays the container images and namespace owners

.DESCRIPTION
After logging into Azure, the script cycles through each subscription and retrieves all associates AKS clusters. For each cluster, the script lists all deployments and displays the container iamges and namespace owners. The results are compiled into a CSV file for easy review and reporting.

Of special note - This script is highly taxing on local machine and takes multipel hours to run.

Assumptions:
    Powershell
    Authentication in AZ CLI

.EXAMPLE
Running this script...
    Choose a starting index # Currently, there are 160+ subscriptions in AKS
    ./aks-container-images.ps1 -StartIndex 1 -EndIndex 10
     --or--
    ./aks-container-images.ps1 -StartIndex 11 -EndIndex 20
     --or--
    Chosse an index that suits the users needs
#>

param(
    [int]$StartIndex = 1,
    [int]$EndIndex = 160
)

# Create an empty CSV with headers
$csvPath = ".\ContainerInfo.csv"
if(!(Test-Path $csvPath)) {
    [PSCustomObject]@{
        Subscription            = ""
        SubscriptionProgress    = ""
        Cluster                 = ""
        ClusterProgress         = ""
        Namespace               = ""
        ContainerName           = ""
        NamespaceContactName    = ""
    } | Export-Csv -Path $csvPath -NoTypeInformation
}

$subscriptions = az account list --query "[].{id:id, name,name}" -o json | ConvertFrom-Json
$subscriptionCount = $subscriptions.Count

# Loop only through specified slice (make sure end index doesn't exceed array count)
for ($i = $StartIndex - 1; $i -le $EndIndex - 1 -and $i -lt $subscriptionsCount; $i++) {
    $subscriptions = $subscription[$i]
    $subscriptionIndex = $i + 1
    Write-Host "Processing subscription ${subscriptionIndex} of ${subscriptionCount}: $subscription"
    try {
        az account set --subscription $subscription.id
    } catch {
        Write-Host "Failed to set subscription $($subscription.name). Error: $_"
        continue
    }

    try {
        $clusters = az aks list --query "[].{name:name, rg:resourceGroup}" -o json | ConvertFrom-Json
    } catch {
        Write-Host "Failed to list AKS clusters for subscription $($subscription.name). Error: $_"
        continue
    }

    $clusterCount = $clusters.Count
    $clusterIndex = 0
    if ($clusterCount -eq 0) {
        $resultObject = [PSCustomObject]@{
            Subscription            = $subscription.name
            SubscriptionProgress    = "subscription $subscriptionIndex of $subscriptionCount"
            Cluster                 = ""
            ClusterProgress         = ""
            Namespace               = ""
            ContainerImage          = ""
            NamespaceContactName    = ""            
        }
        $resultObject | Export-Csv -Path $csvPath -NoTypeInformation -Append
    } else {
        foreach ($cluster in $clusters) {
            $clusterIndex++
            Write-Host " Processing cluster ${clusterIndex} of ${clusterCount}: $($cluser.name)"
            $clusterName = $cluster.name
            $resourceGroup = $cluster.rg

            Write-Host "Checking cluster: $clusterName in resource group: $resourceGroup"

            ### The following code only needs to run the first time to populate all of the contexts
            # az aks get-credentials --resource-group $resourceGroup --name $clusterName --overwrite-existing
            # kubelogin convert-kubeconfig -l azurecli
            kubectl config use-context $clusterName

            # Get all namespaces
            try {
                $namespaces = kubectl get namespaces --no-headers | ForEach-Object { ($_ -split '\s+')[0] }
                if ($LASTEXITCODE -ne 0 -or -not $namespaces) {
                    Write-Host "kubectl get namespaces failed for cluster $clusterName."
                    continue
                }
            } catch {
                Write-Host "Error retrieving namespaces for cluster $clusterName. Details: $_"
                continue
            }

            foreach ($namespace in $namespaces) {
                try {
                    $nsDetails = kubectl get namespace $namespace -o json | ConvertFrom-Json
                    $nsLabels = $nsDetails.metadata.labels
                    $NamespaceContactName = ""
                    if ($nsLabels -and $snLabels.'ns-contact-name') {
                        $NamespaceContactName = $nsLabels.'ns-contact-name'
                    }
                } catch {
                    $NamespaceContactName = ""
                }

                try {
                    $deployList = kubectl get deployments -n $namespace -o json | ConvertFrom-Json
                    foreach ($deploy in $deployList.items) {
                        $deployName = $deploy.metadata.name
                        $containerImages = $deploy.spec.template.spec.containers | ForEach-Object { $_.image }
                        $imageString = $containerImages -join ", "
                        $resultObject = [PSCustomObject]@{
                            Subscription            = $subscription.name
                            SubecriptionProgress    = "Subscription $subscriptionIndex of $subscriptionCount"
                            Cluster                 = $clusterName
                            CluserProgress          = "Cluster $clusterIndex of $clusterCount"
                            Namespace               = $namespace
                            Deployment              = $deployName
                            ContainerImage          = $imageString
                            NamespaceContactName    = $namespaceContactName
                        }
                        $resultObject | Export-Csv -Path $csvPath -NoTypeInformation -Append
                    }
                } catch {
                    Write-Host "Error retrieving Deployments for namespace $namespace. Details: $_"
                    continue
                }
            }
        }
    }
}

Write-Host "Results have been exported to ContinerInfo.csv"