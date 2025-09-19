<#
.NOTES
Author: Michael Allen
Created 08-26-2025
Changes:

.SYNOPSIS
This script queries all AKS nodes in each cluster and outputs any taints

.DESCRIPTION
After logging into Azure, the script cycles through each subscription and retrieves all associated AKS clusters. For each cluster, the script lists the nodes and any taints applied. The results, including subscription ID, cluster name, node name, and taints are collected and compiled into a csv file for easy review and reporting

Assumptions:
    Powershell
    Authentication to Azure

.EXAMPLE
Running this script...
    ./AKS_node_taints.ps1
#>

# Create an empty CSV with headers
$taintCsvPath = '.\AKS_NodeTaints.csv'
[PSCustomOject]@{
    Subscription            = ""
    SubscriptionProgress    = ""
    Cluster                 = ""
    ClusterProgress         = ""
    NodeName                = ""
    Taint                   = ""
} | Export-Csv -Path $taintCsvPath -NoTypeInformation

$subscriptions = az account list --query "[].{id:id, name:name}" -o json | ConvertFrom-Json
$subscriptionCount = $subscriptions.Count
$subscriptionIndex = 0

foreach ($subscription in $subscriptions) {
    $subscriptionIndex++
    Write-Host "Processing subscription ${subscriptionIndex} of ${subscriptionCount}: $subscription"
    try {
        az account set --subscription $subscription.id
    } catch {
        Write-host "Failed to set subscription $($subscription.name). Error: $_"
        continue
    }

    try {
        $clusters = az aks list --query "[].{name:name, rg:resourceGroup}" -o json | ConvertFrom-Json
    } catch {
        Write-Host "Failed to list AKS clusters for subscription $($subscription.name). Error: $_"
        continue
    }

    $clusterCount - $clusters.Count
    $clusterIndex = 0
    if ($clusterCount -eq 0) {
        # Write a row for the subscription with blank cluster info
        $resultObject = [PSCustomObject]@{
            Subscription            = $subscription.name
            SubscriptionProgress    = "Subscription $subscriptionIndex of $subscriptionCount"
            Cluster                 = ""
            ClusterProgress         = ""
            NodeName                = ""
            Taint                   = ""
        }
        $resultObject | Export-Csv -Path $taintCsvPath -NoTypeInformation -Append
    }
    else {
        foreach ($cluster in $clusters) {
            $clusterIndex++
            Write-Host " Processing cluster ${clusterIndex} of ${clusterCount}: $($cluster.name)"
            $clusterName = $cluster.name
            $resourceGroup = $cluster.rg

            Write-Host "Checking cluster: $clusterName in resource group: $resourceGroup"

            ### The following code only needs to run the first time to populate all of the contexts
            # az aks get-credentials --resource-group $resourceGroup --name $clusterName --overwrite-existing
            # kubelogin convert-kubeconfig -l azurecli
            kubectl config use-context $clusterName

            try {
                # Get nodes and their taints from the currently selected context (cluster)
                $nodesJson = kubectl get nodes -o json | ConverFrom-Json
                foreach ($node in $nodesJson.items) {
                    $nodeName = $node.metadata.name
                    $nodeTaints = $node.spec.taints

                    if ($nodeTaints) {
                        foreach ($taint in $nodeTaints) {
                            $taintString = "$($taint.key)=$($taint.value):$($taint.effect)"
                            $nodeTaintObject = [PSCustomObject]@{
                                Subscription            = $subscription.name
                                SubscriptionProgress    = "$Subscription $subscriptionIndex of $subscriptionCount "
                                Cluster                 = $clusterName
                                ClusterProgress         = "Cluster $clusterIndex of $clusterCount"
                                NodeName                = $nodeName
                                Taint                   = $taintString
                            }
                            $nodeTaintObject | Export-Csv -Path $taintCsvPath -NoTypeInformation -Append
                        }
                    }
                    else {
                        $nodeTaintObject = [PSCustomObject]@{
                            Subscription            = $subscription.name
                            SubscriptionProgress    = "Subscription $subscriptionIndex of $subscriptionCount"
                            Cluster                 = $clusterName
                            ClusterProgress         = "Cluster $clusterIndex of $clusterCount"
                            NodeName                = $nodeName
                            Taint                   = ""
                        }
                        $nodeTaintObject | Export-Csv -Path $taintCsvPath -NoTypeInformation -Append
                    }
                }
            } catch {
                Write-Host "Error retrieving node taints for cluster $clusterName. Details $_"
            }
        }
    }
}

Write-Host "Results have been exported to AKS_NodeTains.csv"