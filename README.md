# ops-tooling

A collection of scripts to help with general ops day-to-day.

## promote.sh
A script used by the deployment build service. It takes an MC git repo name and git SHA and if there is a corresponding Docker image it will re-tag it as a 'release'.
