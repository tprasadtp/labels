#!/bin/bash
set -eo pipefail
readonly SCRIPT=$(basename "$0")
readonly YELLOW=$'\e[1;33m'
readonly GREEN=$'\e[1;32m'
readonly RED=$'\e[1;31m'
readonly BLUE=$'\e[1;34m'
readonly NC=$'\e[0m'
readonly UPSTREAM_URL="https://github.com/hackebrot/labels"

function print_info()
{
  printf "✦ %s \n" "$@"
}

function print_success()
{
  printf "%s✔ %s %s\n" "${GREEN}" "$@" "${NC}"
}

function print_warning()
{
  printf "%s⚠ %s %s\n" "${YELLOW}" "$@" "${NC}"
}

function print_error()
{
   printf "%s✖ %s %s\n" "${RED}" "$@" "${NC}"
}

function print_notice()
{
  printf "%s✦ %s %s\n" "${BLUE}" "$@" "${NC}"
}


function display_usage()
{
#Prints out help menu
cat <<EOF
Usage: ${GREEN}${SCRIPT} ${BLUE}  [options]${NC}

Adds Upstream remote URL for this repo and disables
push for it.
-----------------------------------------------------------
[-u --upstream]           [Configure upstream]
[-D --dont-disable-push]  [Don't disable push for upstream]
[-h --help]               [Display this help message]
EOF
}

function disable_upstream_push()
{
  local upstream_url_push
  # check if push needs to be disabled
  if [[ $dont_disable_upstream_push != "true" ]]; then
    if [[ $(git remote get-url --push upstream) == "DISABLED" ]]; then
      print_success "Upstream push is already disabled"
    else
      print_notice "Disabling upstream push"
      if git remote set-url --push upstream DISABLED > /dev/null 2>&1; then
        print_success "Done"
      else
        print_error "Failed to disable upstream push"
      fi
    fi
  else
    if [[ $(git remote get-url --push upstream) == "DISABLED" ]]; then
      print_success "Enabling upstream push"
      if git remote set-url --push upstream "${UPSTREAM_URL}" > /dev/null 2>&1; then
        print_success "Done"
        return
      else
        print_error "Failed to enable upstream push"
      fi
    fi
    print_info "Not disabling upstream push"
  fi

}

function configure_upstream()
{
  local upstream_url
  if upstream_url=$(git remote get-url upstream 2>/dev/null ); then
    if [[ $upstream_url == "$UPSTREAM_URL" ]]; then
      print_success "Upstream already exists"
      disable_upstream_push
    else
      print_warning "Remote 'upstream' exists and has a different URL"
      exit 2
    fi
  else
    print_notice "There seems to be no remote named upstream, adding now"
    if git remote add upstream "${UPSTREAM_URL}" > /dev/null 2>&1; then
      print_success "Added ${UPSTREAM_URL} as upstream"
      disable_upstream_push
    else
      print_error "Failed to add upstream remote ${UPSTREAM_URL}"
      exit 1
    fi
  fi
}

function main()
{
  #check if no args
  if [ $# -lt 1 ]; then
    print_error "No arguments specified! See usage below."
    display_usage;
    exit 1;
  fi;

  while [ "${1}" != "" ]; do
    case ${1} in
      -D | --dont-disable-push )  dont_disable_upstream_push="true"
                                  ;;
      -u| --upstream )            upstream_action="true";
                                  ;;
      -h | --help )               display_usage;
                                  exit $?
                                  ;;
      * )                         print_error "Invalid argument(s). See usage below."
                                  usage;
                                  exit 1
                                  ;;
    esac
    shift
  done

if [[ $upstream_action == "true" ]]; then
  configure_upstream
else
  print_error "Did you forget to pass -u | --upstream?"
  exit 1
fi
}

main "$@"