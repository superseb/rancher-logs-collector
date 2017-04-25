#!/bin/bash


type rancher >/dev/null 2>&1 || { echo >&2 "I require rancher CLI but it's not installed.  Aborting."; exit 1; }

# TODO: Print instructions for downloading/setting up CLI.


LOGS_DIR=`mktemp -d -t rancher.logs`

echo "Collecting logs to directory: ${LOGS_DIR}"

cd ${LOGS_DIR}

# TODO: Check for exit codes

rancher host ls -a > rancher_host.log 2>&1
rancher ps -s -a > rancher_ps_s_a.log 2>&1
rancher ps -c -a > rancher_ps_c_a.log 2>&1

echo "Collecting rancher-agent logs"
rancher ps -c -a -s | grep rancher-agent | awk '{system("rancher logs --tail=-1 "$1" > "$2"-"$5"-"$1".log 2>&1");}'

echo "Collecting ipsec logs"
rancher ps -c -a -s | grep ipsec | awk '{system("rancher logs --tail=-1 "$1" > "$2"-"$5"-"$1".log 2>&1");}'

echo "Collecting network-services logs"
rancher ps -c -a -s | grep network-services | awk '{system("rancher logs --tail=-1 "$1" > "$2"-"$5"-"$1".log 2>&1");}'

echo "Collecting healthcheck logs"
rancher ps -c -a -s | grep healthcheck | awk '{system("rancher logs --tail=-1 "$1" > "$2"-"$5"-"$1".log 2>&1");}'

echo "Collecting scheduler logs"
rancher ps -c -a -s | grep scheduler | awk '{system("rancher logs --tail=-1 "$1" > "$2"-"$5"-"$1".log 2>&1");}'

echo "Please compress the folder ${LOGS_DIR} and send them across to Rancher Support"
