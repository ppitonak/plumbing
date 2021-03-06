#!/usr/bin/env bash
set -eu
TIMESTAMP=$(date '+%Y%m%d-%Hh%M-%S')
NS=tekton-pipeline-tests-${TIMESTAMP}
failed=0
export BUILD_NUMBER=1

oc new-project ${NS}

source test/e2e-common.sh

#kubectl get ns|grep arendelle|awk '{print $1}'|xargs kubectl delete ns
#export TEST_KEEP_NAMESPACES=true

# Run the integration tests
header "Running Go e2e tests"

/usr/local/go/bin/go test -v -failfast -count=1 -tags=e2e \
  -ldflags '-X github.com/tektoncd/pipeline/test.missingKoFatal=false -X github.com/tektoncd/pipeline/test.skipRootUserTests=true' \
  ./test -timeout=30m --kubeconfig=${KUBECONFIG}  || failed=1


(( failed )) && fail_test

header "Cleaning up test namespaces"
kubectl delete ns ${NS}
for i in $(kubectl get ns|grep '^arendelle'|awk '{print $1}');do
  kubectl delete ns ${i} || true
done

success
