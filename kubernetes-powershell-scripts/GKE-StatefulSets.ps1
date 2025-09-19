<#
.NOTES
Author: Michael Allen
Created 08-21-2025
Changes:

.SYNOPSIS
This script queries stateful sets in all GKE clusters and identifies teams based on labels.

.DESCRIPTION
After logging into Google Cloud, the script cycles through each project and retrieves all associated GKE clusters. The results, including details such as project ID, cluster name, namepsace, stateful set name, readiness status, age, cluster application owner are written to a file. Application Owner and Namespace Contact (via labels), are collected and filter to exclude clusters without StatefulSets.
The script exports the results into CSV for easy review.

.EXAMPLE
Running this script...
    ./GKE-StatefulSets.ps1
#>

# Ensure Cloud SDK is active
gcloud auth login

# Create an empty CSV with headers
$csvPath = ".\GKE_StatefulSets.csv"
[PSCustomObject]@{
    ProjectID                   = ""
    ProjectName                 = ""
    ProjectProgress             = ""
    Cluster                     = ""
    ClusterLocation             = ""
    ClusterProgress             = ""
    Namespace                   = ""
    StatefulSet                 = ""
    Ready                       = ""
    Age                         = ""
    ClusterApplicationOwner     = ""
    ApplicationOwner            = ""
    NamespaceContactName        = ""
} | Export-Csv -Path $csvPath -NoTypeInformation -Encoding utf8

# List all active projects
$projects = gcloud projects list --format="json" | ConvertFrom-Json
$ProjectCount = $projects.Count
$ProjectIndex = 0

foreach ($project in $projects) {
    $projectIndex++
    Write-Host "Processing project ${projectIndex} of ${projectCount}: $(project.projectId) ($($projects.name))"
    $projectId  = $project.projectId
    $projectName = $project.name

    # List GKE clusters in this project
    try {
        $clusters = gcloud container clusters list --project $projectId --format="json" | ConvertFrom-Json
    } catch {
        Write-Host "Failed to list clusters for project $projectId. Error: $_"
        continue
    }

    $clusterCount = $clusters.Count
    $clusterIndex = 0
    if ($clusterCount -eq 0) {
        # Write a row for the project with blank cluster info
        $resultObject = [PSCustomObject]@{
            projectID                   = $projectId
            projectName                 = $projectName
            projectProgress             = "project $projectIndex of $projectCount"
            Cluster                     = ""
            ClusterLocation             = ""
            ClusterProgress             = ""
            Namespace                   = ""
            StatefulSet                 = ""
            Ready                       = ""
            Age                         = ""
            ClusterApplicationOwner     = ""
            ApplicationOwner            = ""
            NamespaceContactName        = ""
        }
        $resultObject | Export-Csv -Path $csvPath -NoTypeInformation -Append -Encoding utf8
    } else {
        foreach ($cluster in $clusters) {
            $clusterIndex++
            $clusterName = $cluster.name
            $clusterLocation = $cluster.location

            Write-Host "Processing cluster ${clusterIndex} of ${clusterCount}: $clusterName ($ClusterLocation)"

            # Get cluster resource labels if available
            $clusterApplicationOwner = ""
            if ($cluster.resourceLabels.'application-owner') {
                $clusterApplicationOwner = $cluster.resourceLabels.'application-owner'
            }

            # Get credentials for clutser (requrires gcloud auth and neccessary permissions)
            try {
                gcloud container clusters get-credentials $clusterName --project $projectId --zone $ClusterLocation
            } catch {
                Write-Host " Could not get credentials for cluster $clusterName. Skipping."
                continue
            }

            # List namespaces
            try {
                $namespaces = kubectl get namespaces --no-headers | ForEach-Object { ($_ -split '\s+')[0] }
            } catch {
                Write-Host "Error retrieving namespaces for cluster $clusterName. Skipping"
                continue 
            }
            
            foreach ($namespace in $namespaces) {
                try {
                    $statefulSets = kubectl get statefulset -n $namespace --no-headers 2>$null
                } catch {
                    Write-Host "Error fetching statefulsets for namespace $namespace"
                    continue 
                }
                
                if ($statefulSets) {
                    try {
                        $nsDetails = kubectl get namespace $namespace -o json | ConvertFrom-Json
                    } catch {
                        Write-Host "Error fetching namespace labels for $namespace"
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
                            project                     = $project.name
                            projectProgress             = "project $projectIndex of $projectCount"
                            Cluster                     = $clusterName
                            ClusterProgress             = "Cluster $clusterIndex of $clusterCount"
                            Namespace                   = $namespace
                            StatefulSet                 = $ssName
                            Ready                       = $ssReady
                            Age                         = $ssAge
                            ApplicationOwner            = $ApplicationOwner
                            ClusterApplicationOwner     = $clusterApplicationOwner
                            NamespaceContactName        = $NamespaceContactName
                        }
                        $resultObject | Export-Csv -Path $csvPath -NoTypeInformation -Append -Encoding utf8
                    }
                
                }
            }
        } 
    }
}

Write-Host "Results have been exported to AKS_StatefulSets.csv"