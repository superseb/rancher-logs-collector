#!/bin/bash


type rancher >/dev/null 2>&1 || { echo >&2 "I require rancher CLI but it's not installed.  Aborting."; exit 1; }

# TODO: Print instructions for downloading/setting up CLI.


LOGS_DIR=`mktemp -d -t rancher.logs.XXXXXX`

echo "Collecting logs to directory: ${LOGS_DIR}"

cd ${LOGS_DIR}

# TODO: Check for exit codes

rancher host ls -a > rancher_host.log 2>&1
rancher ps -s -a > rancher_ps_s_a.log 2>&1
rancher ps -c -a > rancher_ps_c_a.log 2>&1

CONTAINERS=`rancher ps -c -a -s`

echo "Collecting rancher-agent logs"
echo "${CONTAINERS}" | grep rancher-agent | awk '{system("rancher logs --tail=-1 "$1" > "$2"-"$5"-"$1".log 2>&1");}'

echo "Collecting ipsec logs"
echo "${CONTAINERS}" | grep ipsec | awk '{system("rancher logs --tail=-1 "$1" > "$2"-"$5"-"$1".log 2>&1");}'

echo "Collecting ipsec information"
IPSEC_ROUTERS=`echo "${CONTAINERS}" | grep ipsec-router | awk '{print $1}'`
for ipsec_router_id in ${IPSEC_ROUTERS}; do
    rancher exec ${ipsec_router_id} bash -cx "swanctl --list-conns && swanctl --list-sas && ip -s xfrm state && ip -s xfrm policy && cat /proc/net/xfrm_stat && sysctl -a" > ipsec.info.${ipsec_router_id}.log 2>&1
done

echo "Collecting network-services logs"
echo "${CONTAINERS}" | grep network-services | awk '{system("rancher logs --tail=-1 "$1" > "$2"-"$5"-"$1".log 2>&1");}'

echo "Collecting other networking information"
NM_CONTAINERS=`echo "$CONTAINERS" | grep network-services-network-manager | awk '{print $1}'`
for network_manager_id in ${NM_CONTAINERS}; do
    rancher exec ${network_manager_id} bash -cx "ip link && ip addr && ip neighbor && ip route && conntrack -L && iptables-save && sysctl -a && cat /etc/resolv.conf && uname -a" > nm.network.info.${network_manager_id}.log 2>&1
done

echo "Collecting healthcheck logs"
echo "${CONTAINERS}" | grep healthcheck | awk '{system("rancher logs --tail=-1 "$1" > "$2"-"$5"-"$1".log 2>&1");}'

echo "Collecting scheduler logs"
echo "${CONTAINERS}" | grep scheduler | awk '{system("rancher logs --tail=-1 "$1" > "$2"-"$5"-"$1".log 2>&1");}'


echo "Please compress the folder ${LOGS_DIR} and send them across to Rancher Support"
