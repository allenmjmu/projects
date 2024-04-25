#!/bin/bash

echo What branch do you want to move to?
read BRANCH_NAME

# List of all directories
REPOS=(
    "/Users/<username>/<repo-name>"
    # List other repos here
)

# Loop through each repository in the directory
for repo in ${REPOS[@]}; do
    echo "Moving to $BRANCH_NAME in $repo"
    cd $repo 
    git checkout $BRANCH_NAME
    echo
done
