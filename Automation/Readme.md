# Scripts for daily tasks

## checkout-master.sh

Every day in multiple repositories, developers are pushing code. It becomes very time consuming to checkout the "master" branch in every repo and pull the latest code changes. In my case, there are 4 different development teams working on code at the same time. There are hundreds of commits per day.

The user defines the name of the "master" branch. (main, development, master, etc.) The script then checks out the "master" branch, pulls the latest code, and then runs a git fetch -p to prune any deleted branches from the user's local environment.

## create-new-branch.sh

This script allows the user to create a new feature branch for every repository with the same name. An example of this would be updating an agent pool in all pipeline.yaml files in every repository.

## checkout-branch.sh

When creating the same change in multiple repositories, it is helpful to checkout a feature branch for each repository. This script completes that task for all repositories listed.

## daily-git

This is a combination of checkout-master.sh and checkout-branch.sh. It pulls the latest code from the "master" branch and then checks out the feature branch.

## cron-job.sh

This is not really a script, but an edit to the crontab on a Mac computer. Editing the crontab to complete certain tasks as a cronjob, using cron notation.

### Schedules Format

mm HH DD MM DW
    mm = Minutes 0-59
    HH = Hours 0-23
    DD = Days 1-31
    MM = Months 1-12
    DW = Day of the Week 0-6 (0=Sunday, 6=Saturday)

## encode-base64.sh

This is not a script, but a reminder of how to encode/decode in base64

## pull-all-ai.sh

This is a sample script created by ChatGPT for pulling code from the "master" branch.
