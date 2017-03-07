#!/usr/bin/env bash

set -eu
export LC_ALL=C

host_pattern=${1:-".*"}

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

function delete_host {
    local host=$1
    echo "Deleting ${host} node..."

    virsh destroy ${host}
    virsh undefine ${host}
    rm -f ${LIBVIRT_PATH}/${host}.qcow2
    rm -rf ${LIBVIRT_PATH}/${host}
}

if [[ 'lb' =~ ${host_pattern} ]]; then
    delete_host 'lb'
fi

i=1
for HOST in ${MASTERS}; do
    HOST="master$(printf "%02d" $i)"
    if [[ ${HOST} =~ ${host_pattern} ]]; then
        delete_host ${HOST}
    fi
    i=$((i+1))
done

i=1
for HOST in ${WORKERS}; do
    HOST="worker$(printf "%02d" $i)"
    if [[ ${HOST} =~ ${host_pattern} ]]; then
        delete_host ${HOST}
    fi
    i=$((i+1))
done

if [[ ${host_pattern} = ".*" ]]; then
    echo "Delete cached discovery_url"
    cache_file=${ETCD_DISCOVERY_URL_CACHE_FILE:-"${ROOT}/.discovery_url.cache"}
    if [[ -f ${cache_file} ]]; then
        rm -f ${cache_file}
    fi
fi