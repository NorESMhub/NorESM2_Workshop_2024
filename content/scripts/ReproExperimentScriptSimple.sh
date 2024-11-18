#! /bin/bash
## Run an out-of-the-box N2000 experiment for 3 months
##    but with reduced output.

## Experiment basics, modify these for your experiment
TAG="release-noresm2.0.9"
COMPSET="N2000"
RES="f19_tn14"
SRCROOT="/cluster/projects/nn9039k/xxUSERxx/NorESM"
CASEDIR="/cluster/work/users/xxUSERxx/cases/${COMPSET}_${RES}"
REPO="https://github.com/NorESMhub/NorESM"
PROJECT="nn9039k"

## (make sure that clone exists, otherwise, clone REPO)
if [ ! -d "${SRCROOT}" ]; then
    git clone -o NorESM ${REPO} ${SRCROOT}
fi

## Ensure correct source is checked out
cd ${SRCROOT}
git checkout ${TAG}
./manage_externals/checkout_externals

## Create your case
## Because the TAG above is a techical release most compset / res
##    combinations are unsuported.
./cime/scripts/create_newcase --case ${CASEDIR} --compset ${COMPSET} --res ${RES} \
    --mach betzy --project ${PROJECT} --run-unsupported

## Move to your case directory
cd ${CASEDIR}

## Any PE changes must go here

## Set up the case as configured so far
./case.setup

## Changes that affect the build go here
# Testing a short run first with DEBUG=TRUE is valuable
#    Comment out change for longer runs
#./xmlchange DEBUG=TRUE
./xmlchange STOP_OPTION=nmonths,STOP_N=3

## Build the model
./case.build

## Last chance to modify run-time settings
echo "history_chemistry       = .false." >> user_nl_cam
echo "history_chemspecies_srf = .false." >> user_nl_cam
echo "history_clubb           = .false." >> user_nl_cam

## Submit the job
./case.submit
