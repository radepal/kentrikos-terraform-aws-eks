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
    MAX_ATTEMPTS=18
fi

echo "Tiller-pod readiness probe is using   : $KUBECONFIG"
echo "Tiller-pod readiness probe interval is: $POOL_WAIT_SECONDS"
echo "Tiller-pod maximum readiness attempts : $MAX_ATTEMPTS"
echo "Maximum wait time for Tiller-pod to come on-line: $(expr ${POOL_WAIT_SECONDS} \* ${MAX_ATTEMPTS}) seconds."
sleep ${POOL_WAIT_SECONDS}
nodes=$(kubectl --kubeconfig=$KUBECONFIG get pod --all-namespaces 2>&1)
#nodes=$(cat nodes.txt)  # for internal testing 
tiller_pods=$(echo -n "${nodes}" | grep ' tiller-' | grep ' Running ' | wc -l)
iterator=0

while [[ $tiller_pods -ne 1 ]]; do
    iterator=$((iterator+1))
    echo "Tiller-pod readiness probe attempt #${iterator} out of ${MAX_ATTEMPTS}"
    sleep ${POOL_WAIT_SECONDS}

    nodes=$(kubectl --kubeconfig=$KUBECONFIG get pod --all-namespaces 2>&1)
    #nodes=$(cat nodes.txt)  # for internal testing 
    tiller_pods=$(echo -n "${nodes}" | grep ' tiller-' | grep ' Running ' | wc -l)
    if [[ "${iterator}" -eq "${MAX_ATTEMPTS}" ]]; then
        echo "FAILED tiller_pods readiness probe ...." 
        exit 1
    else
        continue
    fi
done
sleep ${POOL_WAIT_SECONDS}
sleep ${POOL_WAIT_SECONDS}
echo "Tiller-Pod is running...  continuing."
exit 0

