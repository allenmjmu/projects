#!/bin/bash

# Checkout development branch first
./ME-checkout-master.sh

# Declare Branch Name
echo What is the new branch name?
read BRANCH_NAME

# List of all directories
REPOS=(
    "/Users/<username>/<repo-name>"
    # List other repos"
)

# Loop through each repository in the directory
for repo in ${REPOS[@]}; do
    # Pring the repository name
    echo "Creating new branch '$BRANCH_NAME' in $repo"

    # Change directory
    cd $repo

    # Create new branch
    git checkout -b "$BRANCH_NAME"
    echo
done
