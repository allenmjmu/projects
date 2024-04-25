#!/bin/bash
echo "In what environment are you working (dev, qa, perf, stage, prod, on-prem)?"

read ENVIRONMENT

if [ "$ENVIRONMENT" == "dev" ]; then
    ENVIRONMENT_DOMAIN_NAME=<FQDN>

elif [ "$ENVIRONMENT" == "qa" ]; then
    ENVIRONMENT_DOMAIN_NAME=<FQDN>

elif [ "$ENVIRONMENT" == "perf" ]; then
    ENVIRONMENT_DOMAIN_NAME=<FQDN>

elif [ "$ENVIRONMENT" == "stage" ]; then
    ENVIRONMENT_DOMAIN_NAME=<FQDN>

elif [ "$ENVIRONMENT" == "prod" ]; then
    ENVIRONMENT_DOMAIN_NAME=<FQDN>

elif [ "$ENVIRONMENT" == "on-prem" ]; then
    ENVIRONMENT_DOMAIN_NAME=<FQDN>
fi

echo "You are creating a certificate signing request (csr) for the $ENVIRONMENT environment. Please use the following arguments:"
echo "Country Name: US"
echo "State Name: <insert>"
echo "Locality Name: <insert>"
echo "Organization Name: <insert>"
echo "Organization Unit: <insert>"
echo "Common Name: $ENVIRONMENT_DOMAIN_NAME"
echo "Email Address: <insert>"
echo "Challenge Password: Anything you choose. Document in secure location"

cd /<working directory>
mkdir -p $ENVIRONMENT
cd $ENVIRONMENT

# create key and certificate signing request (csr)
openssl req -new -newkey rsa:2048 -nodes -keyout $ENVIRONMENT-<product-name>.key -out $ENVIRONMENT-<product-name>.csr

cat $ENVIRONMENT-<product-name>.csr

echo "Copy key to your clipboard"
echo "Paste into ServiceNow Link"
echo "<SNOW link>"
echo "2024 WBS Code - <billing code>"

# to read the key, use the following command:
# openssl req -text -noout -verify $ENVIRONMENT-<product-name>.csr