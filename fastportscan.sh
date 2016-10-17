#!/bin/bash 
#author:L.N.
#date:2016/10/17

function usage {
    echo "Usage: $0 -t targets.txt [-e PATH] [-h]"
    echo "       -h: Help"
    echo "       -t: File containing ip addresses to scan. This option is required."
    echo "       -e: masscan's path (ex: /root/masscan/bin/)."
}


if [[ ! $(id -u) == 0 ]]; then
    echo "[!] This script must be run as root"
    exit 1
fi

if [[ -z $1 ]]; then
    usage
    exit 0
fi

targets=""
masscan_path=""

while getopts "t:e:h" OPT; do
    case $OPT in
        t) targets=${OPTARG};;
        e) masscan_path=${OPTARG};;
        h) usage; exit 0;;
        *) usage; exit 0;;
    esac
done

if [[ -z $targets ]]; then
    echo "[!] No target file provided"
    usage
    exit 1
fi

if [[ -z $masscan_path ]]; then
    echo "[!] No Masscan path povided"
    usage
    exit 1
fi

echo "[+] Masscan's path: ${masscan_path}"
echo "[+] Targets: ${targets}"


# backup any old scans before we start a new one
mydir=$(dirname $0)
mkdir -p "${mydir}/backup/"
if [[ -d "${mydir}/ndir/" ]]; then 
    mv "${mydir}/ndir/" "${mydir}/backup/ndir-$(date "+%Y%m%d-%H%M%S")/"
fi
if [[ -d "${mydir}/udir/" ]]; then 
    mv "${mydir}/udir/" "${mydir}/backup/udir-$(date "+%Y%m%d-%H%M%S")/"
fi 

rm -rf "${mydir}/ndir/"
mkdir -p "${mydir}/ndir/"
rm -rf "${mydir}/udir/"
mkdir -p "${mydir}/udir/"

while read ip; do
    echo "[+] Scanning $ip for 1-65535 ports..."

    # masscan identifies all open TCP ports
    echo "[+] Obtaining all open TCP ports using masscan..."
    echo "[+] ${masscan_path}masscan -p1-65535 ${ip} --rate=10000 --output-format list --output-filename ${mydir}/udir/${ip}-tcp.txt"
        ${masscan_path}masscan -p1-65535 ${ip} --rate=10000 --output-format list --output-filename ${mydir}/udir/${ip}-tcp.txt > /dev/null 2>&1
        ports=$(cat "${mydir}/udir/${ip}-tcp.txt" | grep open | cut -d" " -f3 | sed 's/ //g' | tr '\n' ',')
        if [[ ! -z $ports ]]; then 
            # nmap follows up
            echo "[+] Ports for nmap to scan: $ports"
            echo "[+] nmap -Pn -sC -T4 -sT -oX ${mydir}/ndir/${ip}-tcp.xml -oG ${mydir}/ndir/${ip}-tcp.grep -p ${ports} ${ip}"
            nmap -Pn -sC -T4 -sT -oX ${mydir}/ndir/${ip}-tcp.xml -oG ${mydir}/ndir/${ip}-tcp.grep -p ${ports} ${ip}
        else
            echo "[!] No TCP ports found"
        fi
done < ${targets}

echo "[+] Scans completed"
