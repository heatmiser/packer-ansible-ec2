#!/bin/bash

# Define constants for all the colors
RED='\e[0;31m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
BLUE='\e[0;34m'
PURPLE='\e[0;35m'
CYAN='\e[0;36m'
WHITE='\e[0;37m'
DARK_GREY='\e[1;30m'
BLACK='\e[0;30m'
BRIGHT_WHITE='\e[1;37m'

# Define constants for bold and underline
BOLD='\e[1m'
UNDERLINE='\e[4m'

# Define a constant for resetting the color
RESET='\e[0m'

# our artifact log file
BUILD_FILE="build_artifact-$(date +%Y-%m-%d.%H%M).txt"

function log()
{
  NORMAL_PRE="${DARK_GREY}[${GREEN}*${DARK_GREY}]${RESET}"
  ERROR_PRE="${DARK_GREY}[${RED}*${DARK_GREY}]${RESET}"

  echo -e "${NORMAL_PRE} ${1}"
}

echo -ne "
${DARK_GREY}
-------------------------------------------------------------------${BLUE}${BOLD}
Satellite AMI ${YELLOW}Golden Image ${BLUE}${BOLD}Builder${DARK_GREY}

GitHub: ${RESET}${CYAN}https://github.com/heatmiser/packer-ansible-ec2${DARK_GREY}
Build log: ${CYAN}${BUILD_FILE}${DARK_GREY}
-------------------------------------------------------------------
${RESET}"

log "Starting packer"

# start packer in background and redirect its output to a file
setsid --fork \
  nohup packer \
  build \
  -machine-readable \
  packer-build.json > "${BUILD_FILE}" 2>&1 </dev/null &

# create a symbolic link to the build file for convience
ln -sf "${BUILD_FILE}" log

log "Created symbolic link ${BLUE}log ${DARK_GREY}-> ${BLUE}${BUILD_FILE}"

log "You may press ${CYAN}CTRL-C${NORMAL} at any time and it will not cancel packer"
log "If you lose connection or logout, the build will continue."
log "To watch the log again just type: ${BLUE}tail -f log${RESET}"
log "To stop packer, type: ${BLUE}pkill -15 packer${NORMAL}"

# monitor contents of the log file in real-time
# Ctrl-C out of tail will _NOT_ send SIGINT to packer since it's forked
# into a different group
adf
log "Watching the output using: ${BLUE}${BOLD}tail -f log${RESET}"

echo -e "${DARK_GREY}-------------------------------------------------------------------"
echo -e "${RESET}"

tail -f log


