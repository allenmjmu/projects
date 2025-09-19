<#
.NOTES
Author: Michael Allen
Created 08-21-2025
Changes:

.SYNOPSIS
This script queries stateful sets in all AKS clusters.

.DESCRIPTION
After logging into Azure, the script cycles through each subscription and retrieves all associated AKS clusters. The results, including details such as subscription ID, cluster name, namepsace, stateful set name, readiness status, age, cluster application owner are written to a file. In addition, namespace labels for application owner and namespace contact name are included.

Assumptions:
    Powershell
    User must have proper permissions in Azure prior to running script

.EXAMPLE
Running this script...
    ./StatefulSets.ps1
    The user can select any subscription when prompted during the "az login" process
    #>

function Get-StatefulSetsWithAuthRetry {
    param (
        [string]$ClusterName
    )

    $maxRetries = 3
    $attempt = 0

    while ($attempt -lt $maxRetries) {
        $statefulSets = kubectl get statefulsets --all-namespaces --no-headers 2>&1

        if ($statefulSets -match "DevideCodeCredential" -or $statefulSets -match "To sign in, use a web browser to open the page") {
            Write-Host "Authentication required. Please follow the instructions above to sign in using the device code."
            Start-Sleep -Seconds 30 # Wait for user to complete sign in
            $attempt++
            continue
        } else {
            return $statefulSets
        }
        catch {
            Write-Host "An error occurred during processing. Details: $_"
        }
    }
    Write-Host "Failed to authenticate after $maxRetries attempts. Skipping cluster $clusterName."
    return $null
}

# Authenticate to az cli
az login

# Create an empty CSV with headers
$csvPath = "AKS_StatefulSets.csv"
[PSCustomObject]@{
    Subscription            = ""
    SubscriptionProgress    = ""
    Cluster                 = ""
    ClusterProgress         = ""
    Namespace               = ""
    StatefulSet             = ""
    Ready                   = ""
    Age                     = ""
    ClusterApplicationOwner = ""
    ApplicationOwner        = ""
    NamespaceContactName    = ""
} | Export-Csv -Path $csvPath -NoTypeInformation -Encoding utf8

$subscriptions = az account list --query "[].{id.id, name:name}" -o json | ConvertFrom-Json
$subscriptionCount = $subscriptions.Count
$subscriptionIndex = 0

foreach ($subscription in $subscriptions) {
    $subscriptionIndex++
    Write-Host "Processing subscription ${subscriptionIndex} of ${subscriptionCount}: $subscription"
    try {
        az account set --subscription $subscription.id
    } catch {
        Write-Host "Failed to set subscription $(subscription.name). Error: $_"
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
        # Write a row for the subscription with blank cluster info
    $resultObject = [PSCustomObject]@{
        Subscription            = $subscription.name
        SubscriptionProgress    = "Subscription $subscriptionIndex of $subscriptionCount"
        Cluster                 = ""
        ClusterProgress         = ""
        Namespace               = ""
        StatefulSet             = ""
        Ready                   = ""
        Age                     = ""
        ClusterApplicationOwner = ""
        ApplicationOwner        = ""
        NamespaceContactName    = ""
    }
    $resultObject | Export-Csv -Path $csvPath -NoTypeInformation -Append -Encoding utf8
    } 
    else {
        foreach ($cluster in $clusters) {
            $clusterIndex++
            Write-Host "Processing cluster ${clusterIndex} of ${clusterCount}: $($cluster.name)"
            $clusterName = $cluster.name
            $resourceGroup = $cluster.rg

            Write-Host "Checking cluster: $clusterName in resource group: $resourceGroup"

            # Get Cluster Tags
            try {
                $clusterInfo = az aks show --resource-group $resourceGroup --name $clusterName -o json | ConvertFrom-Json
            } catch {
                Write-Host "Failed to get AKS cluster info for $clusterName. Error: $_"
                continue
            }

            $clusterTagApplicationOwner = ""
            if ($clusterInfo.tags.'application-owner') {
                $clusterTagApplicationOwner = $clusterInfo.tags.'application-owner'
            }

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
                    $statefulSets = kubectl get statefulset -n $namespace --no-headers 2>$null
                    if ($LASTEXITCODE -ne 0) {
                        Write-Host "kubectl command failed in namespace $namespace of cluster $clusterName."
                    continue 
                    }
                } catch {
                    Write-Host "Error executing kubectl in namespace $namespace of cluster $clusterName. Details: $_"
                    continue 
                }

                if ($statefulSets) {
                    try {
                        $nsDetails = kubectl get namespace $namespace -o json | ConvertFrom-Json
                        if ($LASTEXITCODE -ne 0 -or -not $nsDetails) {
                            Write-Host "kubectl get namespace $namespace failed in cluster $clusterName."
                            continue
                        }
                    } catch {
                        Write-Host "Error retrieving namespace details for $namespace in cluster $clusterName. Details: $_"
                        continue
                    }

                    $nsLabels = $nsDetails.metadata.labels
                    $ApplicationOwner = ""
                    $NamespaceContactName = ""
                    if ($nsLabels) {
                        if ($nsLabels.'application-owner') {
                            $ApplicationOwner = $nsLabels.'application-owner'
                        }
                        if ($nsLabels.'ns-contact-name') {
                            $NamespaceContactName = $nsLabels.'ns-contact-name'
                        }
                    }

                    foreach ($statefulSet in $statefulSets) {
                        $fields = $statefulSet -split '\s+'
                        $ssName = $fields[0]
                        $ssReady = $fields[1]
                        $ssAge = $fields[-1] # Age is usually the last column

                        $resultObject = [PSCustomObject]@{
                            Subscription            = $subscription.name
                            SubscriptionProgress    = "Subscription $subscriptionIndex of $subscriptionCount"
                            Cluster                 = $clusterName
                            ClusterProgress         = "Cluster $clusterIndex of $clusterCount"
                            Namespace               = $namespace
                            StatefulSet             = $ssName
                            Ready                   = $ssReady
                            Age                     = $ssAge
                            ApplicationOwner        = $ApplicationOwner
                            ClusterApplicationOwner = $clusterTagApplicationOwner
                            NamespaceContactName    = $NamespaceContactName
                        }
                    $resultObject | Export-Csv -Path $csvPath -NoTypeInformation -Append -Encoding utf8
                    }
                }
            }
        }

    } 
}

Write-Host "Results have been exported to AKS_StatefulSets.csv"