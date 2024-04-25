### From github co-pilot

#!/bin/bash

# List of GitHub repositories
respositories=(
    "https://github.com/user/repo1.git"
    "https://github.com/user/repo2.git"
    "https://github.com/user/repo3.git"
)

# Directory to clone repositories
clone_dir="/Users/<username>/<repo-name>"

# Checkout development branch and pull code for each repository
for repo in "${repositories[@]}; do
    # Extract repsitory name from URL
    repo_name=$(basename "$repo" .git)

    # Clone or pull the repository
    if [ -d "$clone_dir/$repo_name" ]; then
        echo "Pulling code for $repo_name..."
        cd "$clone_dir/$repo_name"
        git checkout development
        git pull
    else
        echo "Cloning $repo_name..."
        git clone -b development "$repo" "$clone_dir/$repo_name"
    fi 
done
