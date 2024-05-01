# Pipeline Examples

## AWS CI Pipeline

This is an example of both a Continuous Integration (CI) pipeline and a Continous Deployment (CD) pipeline configured for AWS.

The CI pipeline builds continuously by creating a new build of the microservice anytime there is a pull request (pr) or a merge to the development branch. This is run in an Azure DevOps (ADO) pipeline.

### trigger

Anytime a change is made to the development branch, a build is triggered.

### pr trigger

Anytime a pull request is submitted (not necessarily approved), a build is triggered.

### pool

This defines the self-hosted agent pool used in ADO to complete the build. These are usually Linux machines, but sometimes windows.

### resources

To keep things consistent across products, there are a number of templates configured. These templates are not included here. They are merely referenced by using the extend command. The resources section references the templates used in the pipeline.

### parameters

There are numerous options for parameters, but in this case a simple boolean that allows the pipeline user to decide if the database migration scripts are run or not. This shows as a checkbox in ADO.

### extends

This tells the agent what template to use and the path to find it. There are specific stages and dependencies defined. The application is named and each build is labeled using a naming convention. Any variable groups that are needed (stored in the ADO Library) are referenced here. In this case there is also a single variable calling for the build to use the newer Docker Buildkit.

### build

This is the build of the microservice. In this case, the build takes place using a dockerfile, is saved in an private registry, is labeled with an image name, runs a SonarQube scan, uses a specific variable group in the ADO library, finds the Dockerfile in the current git repository, downloads and npm token, sets the working directory, and pushes the completed build to the registry.

## scan

There are multiple options for scanning. In this case the SonarQube scan and NodeJS yarn scans are in the Dockerfile. Since a scan is required as part of the pipeline template a git leaks scan is run here.

## deploy

The only build that will deploy to the development environment must come from the development branch. Any feature branch will build and image, but will not deploy to the environment. This keeps the development environment "clean" with only approved pull requests being deployed.

The kubernetes configuration are pulled from the repository using a folder for each environment, deployed to the specified namespace, and using the defined service account connection from ADO.

Following the deployment, if the boolean parameter was marked "true," a command is run to trigger the database migration script. The agent connects to the kubernetes pod and executes the script as required.

## AWS CD Pipeline

This pipeline is used to deploy to upper environments. In this case, it pulls a specific build from the registry and deploys it to the environment. The only specified parameter here is to use the correct app verion form the registry.
