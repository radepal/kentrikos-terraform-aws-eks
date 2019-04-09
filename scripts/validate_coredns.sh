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
if [ "$#" -ge 3 ]; then
    MAX_ATTEMPTS=$3
else
    MAX_ATTEMPTS=40
fi
if [ "$#" -ge 4 ]; then
    DEBUG=$4
else
    DEBUG=0
fi

dnspod="coredns"

echo "\nDNS readiness probe is using   : $KUBECONFIG"
echo "DNS readiness probe interval is: $POOL_WAIT_SECONDS seconds"
echo "DNS maximum readiness attempts : $MAX_ATTEMPTS times"
echo "Maximum wait time for DNS pods to come on-line: $(expr ${POOL_WAIT_SECONDS} \* ${MAX_ATTEMPTS}) seconds.\n"
sleep ${POOL_WAIT_SECONDS}
running_dns=$(kubectl --kubeconfig=$KUBECONFIG get pod -n kube-system | grep $dnspod | grep -wo Running | wc -l)

if [[ "${DEBUG}" -gt 0 ]]; then
    echo "DEBUG:\n$(kubectl --kubeconfig=$KUBECONFIG get pod -n kube-system)\n"
    echo "Running DNS pods: $running_dns"
fi
iterator=0
 
while (( $running_dns < 1 )); do
    iterator=$((iterator+1))
    echo "DNS readiness probe attempt #${iterator} out of ${MAX_ATTEMPTS}"
    sleep ${POOL_WAIT_SECONDS}
    if [[ "${DEBUG}" -gt 0 ]]; then
        echo "DEBUG:\n$(kubectl --kubeconfig=$KUBECONFIG get pod -n kube-system)\n"
        echo "Running DNS pods: $running_dns"
    fi
    running_dns=$(kubectl --kubeconfig=$KUBECONFIG get pod -n kube-system | grep $dnspod | grep -wo Running | wc -l)
    if [[ "${iterator}" -eq "${MAX_ATTEMPTS}" ]]; then
        echo "\n\n>>>> FAILED <<<<\n\n>>>> CoreDNS readiness probe did not pass.... <<<<<\n"
        kubectl --kubeconfig=$KUBECONFIG get pod -n kube-system
        exit 1
    else
        continue
    fi
done
echo "\n$dnspod is running...  continuing.\n"
exit 0

