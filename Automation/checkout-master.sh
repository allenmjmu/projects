#!/bin/bash

# List of all directories
REPOS_MASTER=(
    "/Users/<username>/<repo-name>"
    # List others with 'master' branch
)
REPOS_MAIN=(
    "/Users/<username>/<repo-name>"
    # List others with a 'main' branch
)
REPOS_DEVELOPMENT=(
    "/Users/<username>/<repo-name>"
    # List others with a 'development' branch
)

# Loop through each repository in the directory with a master branch
for repo_master in ${REPOS_MASTER[@]}: do
    echo "Moving to master branch in $repo_master"
    cd $repo_master
    git checkout master
    git pull
    echo
done 

# Loop through each repository in the directory with a main branch
for repo_main in ${REPOS_MAIN[@]}; do
    echo "Moving to main branch in $repo_main"
    cd $repo_main
    git checkout main
    git pull
    echo
done

# Loop through each repository in the directory with a development branch
for repo_development in ${REPOS_DEVELOPMENT[@]}; do
    echo "Moving to the development branch in $repo_development"
    cd $repo_development
    git checkout development
    git pull
    echo
done
