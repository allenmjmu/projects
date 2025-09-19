<#
.NOTES
Author: Michael Allen
Created: 8-29-2025

.SYNOPSIS
Queries all GKE cluster across GCP projects, lists deployments, container images, and namespace owners

.DESCRIPTION
After loggin into GCP, cycles through each project and retrieves associated GKE clusters. For each GKE cluster, lists all deployments and outputs container images and namespace owner info. Reuslts are compiled into a .csv for reporting and review.

.EXAMPLE
Choose a starting index # Currently there are 540+ projects in GKE
    ./gke-container-images.ps1 -StartIndex 1 -EndIndex 10
        --or--
    ./gke-container-images.ps1 -StartIndex 11 -EndIndex 20
        --or--
    Shoose and index that suits the user's needs
#>

param(
    [int]$StartIndex = 1,
    [int]$EndIndex = 542
)

# Output CSV
$csvPath = ".\GKEContainerInfo.csv"
if (!(Test-Path $csvPath)) {
    [PSCustomObject]@{
        Project                 = ""
        ProjectProgress         = ""
        Cluster                 = ""
        ClusterProgress         = ""
        Namespace               = ""
        Deployment              = ""
        ContainerImage          = ""
        NamespaceContactName    = ""
    } | Export-Csv -Path $csvPath -NoTypeInformation
}

$projects = gcloud projects list --format json | ConvertFrom-Json
$projectCount = $projects.Count

for ($i = $StartIndex - 1; $i -le $EndIndex - 1 -and $i -lt $projectCount; $i++) {
    $project = $project[$i]
    $projectIndex = $i + 1
    Write-Host "Processing project ${projectIndex} of ${projectCount}: $($project.projectId)"

    try {
        gcloud config set project $project.projectId | Out-Null
    } catch {
        Write-Host "Failed to set project $($project.projectId). Error: $_"
        continue
    }

    try {
        $clusters = gcloud container clusters list --format json | ConvertFrom-Json
    } catch {
        Write-Host "Failed to list GKE clusters for project $($project.projectId). Error: $_"
        continue
    }

    $clusterCount = $clusters.Count
    $clusterIndex = 0
    if ($clusterCount -eq 0) {
        $resultObject = [PSCustomObject]@{
            Project                 = $project.projectId
            ProjectProgress         = "Project $projectIndex of $projectCount"
            Cluster                 = ""
            ClusterProgress         = ""
            Namespace               = ""
            Deployment              = ""
            ContainerImage          = ""
            NamespaceContactName    = ""
        }
        $resultObject | Export-Csv -Path $csvPath -NoTypeInformation -Append
    } else {
        foreach ($cluster in $clusters) {
            $clusterIndex++
            Write-Host " Processing cluster ${clusterIndex} of ${clusterCount}: $(cluster.name)"

            # Pull credentials - region/zone differs based on GKE mode
            $zone = $cluster.zone
            $clusterName = $cluster.name
            try {
                glcoud container clusters get-credentials $clusterName --zone $zone --project $project.projectId | Out-Null
            } catch {
                Write-Host "Failed to get credentials for cluster $clusterName. Error: $_"
                continue
            }
            
            # Get all namespaces
            try {
                $namespacesRaw = kubectl get namespaces --no-headers | ForEach-Object { ($_ -split '\s+')[0] }
                $namespaces = $namespacesRaw
            } catch {
                Write-Host "Error retrieving namespaces for cluster $clusterName. Details: $_"
                continue
            }

            foreach ($namespace in $namespaces) {
                # Get Namespace Labels
                try {
                    $nsDetails = kubectl get namespace $namespace -o json | ConverFrom-Json
                    $nsLabels = $nsDetails.metadata.labels
                    $namespaceContactName = ""
                    if ($nsLabels -and $nsLables.'ns-contact-name') {
                        $NamespaceContactName = $nsLabels.'ns-contact-name'
                    } elseif ($nsLabels -and $nsLabels.'owner') {
                        $NamespaceContactName = $nsLabels.'owner'
                    }
                } catch {
                    $NamespaceContactName = ""
                }

                # List Deployments in Namespace
                try {
                    $deployList = kubectl get deployments -n $namespace -o json | Convert-From-Json
                    foreach ($deploy in $deployList.items) {
                        $deployName = $deploy.metadata.name
                        $containerImages = $deploy.spec.template.spec.containers | ForEach-Object { $_.image }
                        $imageString = $containerImages -join ", "
                        $resultObject = [PSCustomObject]@{
                            Project                 = $project.projectId
                            ProjectProgress         = "Project $projectIndex of $projectCount"
                            Cluster                 = "$clusterName"
                            ClusterProgress         = "Cluster $clusterIndex of $clusterCount"
                            Namespace               = $namespace
                            Deployment              = $deployName
                            CountainerImage         = $imageString
                            NamespaceContactName    = $NamespaceContactName
                        }
                        $resultObject | Export-Csv -Path $csvPath -NoTypeInformation -Append
                    } 
                } catch {
                    Write-Host "Error retrieving deployments for namespace $namespace. Details: $_"
                    continue
                }
            }
        }
    }
}

Write-Host "Results have been exported to GKEContainerInfo.csv"