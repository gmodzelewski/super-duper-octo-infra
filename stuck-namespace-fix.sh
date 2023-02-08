!/bin/bash
##kubectl proxy --port=8001 
for NAMESPACE in namespacea, nsb, nsc, ....
do
    cat <<< $(kubectl get namespace $NAMESPACE -o json) > tmp.json
    cat <<< $(jq 'del(.spec.finalizers[] | select(. == "kubernetes"))' tmp.json) > tmp.json
    curl -k -H -s "Content-Type: application/json" -X PUT --data-binary @tmp.json http://127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
    EXISTS=$(kubectl get ns $NAMESPACE 2>&1)
    if [[ "$EXISTS" == *"not found"* ]]; then
        echo "$NAMESPACE either successfully deleted or wasn't there at all"
    else
        echo "Namespace $NAMESPACE still present, operation failed"
    fi
done