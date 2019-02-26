#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
    echo "Illegal number of parameters"
    exit 1
else
    KUBECONFIG=$1
fi
if [ "$#" -gt 1 ]; then
    POOL_WAIT_SECONDS=$2
else
    POOL_WAIT_SECONDS=10
fi
if [ "$#" -eq 3 ]; then
    MAX_ATTEMPTS=$3
else
    MAX_ATTEMPTS=40
fi

echo "DNS readiness probe is using   : $KUBECONFIG"
echo "DNS readiness probe interval is: $POOL_WAIT_SECONDS seconds"
echo "DNS maximum readiness attempts : $MAX_ATTEMPTS times"
echo "Maximum wait time for DNS pods to come on-line: $(expr ${POOL_WAIT_SECONDS} \* ${MAX_ATTEMPTS}) seconds."
sleep ${POOL_WAIT_SECONDS}
nodes=$(kubectl --kubeconfig=$KUBECONFIG get pod --all-namespaces 2>&1)
#nodes=$(cat nodes.txt)  # for internal testing 
running_dns=$(echo -n "${nodes}" | grep 'kube-dns' | grep ' Running '| wc -l)
iterator=0

while [[ $running_dns -ne 1 ]]; do
    iterator=$((iterator+1))
    echo "DNS readiness probe attempt #${iterator} out of ${MAX_ATTEMPTS}"
    sleep ${POOL_WAIT_SECONDS}
    nodes=$(kubectl --kubeconfig=$KUBECONFIG get pod --all-namespaces 2>&1)
    #nodes=$(cat nodes.txt)  # for internal testing 
    running_dns=$(echo -n "${nodes}" | grep 'kube-dns' | grep -v ' Running ' | wc -l)
    if [[ "${iterator}" -eq "${MAX_ATTEMPTS}" ]]; then
        echo "FAILED KUBE-DNS readiness probe ...."
        exit 1
    else
        continue
    fi
done
echo "Kube-DNS is running...  continuing."
exit 0

