# This script checks out each master branch and pulls the latest code
# It then asks for a branch name to checkout for all repos
# This is best used when using the same branch name on all repos

#!/bin/bash

echo "Pull all code on master branch for each repo"
./ME-checkout-master.sh

echo "Checkout working branch for all repos"
./ME-checkout-branch.sh
