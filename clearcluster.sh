#!/bin/bash

atomixNum=1
onosNum=1
netName="dummy-net-name-with-no-refrence"

die() { echo "$1"; exit 1; }

usage() {
  cat <<EOF
    Options:
      -h, --help                  display this help message
      -i, --atomix-num            number of Atomix containers
      -j, --onos-num              number of ONOS containers
      -t, --subnet-name           the custom name for your network
EOF
}

parse_params() {
# Option parsing
  while [ $# -gt 0 ]; do
      case "$1" in
          -h|--help)           usage; exit 0; shift ;;
          -i|--atomix-num)     atomixNum="$2"; shift 2 ;;
          -j|--onos-num)       onosNum="$2"; shift 2 ;;
          -t|--subnet-name)    netName="$2"; shift 2 ;;
          --)                  shift; break ;;
          -*)                  usage; die "Invalid option: $1" ;;
          *)                   break ;;
      esac
  done
  echo "atomix-containers: $atomixNum"
  echo "onos-containers: $onosNum"
  echo "subnet name: $netName"
  read -p $'Are you SURE you want to delete your cluster ? \n(ENTER to continue, CTRL+C to abort)'
}

function delete_Onos() {
  for (( i=1; i<=$onosNum; i++ ))
  do
    sudo docker container rm -f onos-$i
  done
}

function delete_Atomix() {
  for (( i=1; i<=$atomixNum; i++ ))
  do
    sudo docker container rm -f atomix-$i
  done
}

function delete_network() {
  echo "Deleting network: $netName"
  docker network rm -f $netName
}

function main() {
    if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This script requires root privilege !"
    exit 1
    fi

    parse_params "$@"

    delete_Onos
    delete_Atomix
    delete_network

    echo $'\nDone !'
    exit 0
}

main "$@"