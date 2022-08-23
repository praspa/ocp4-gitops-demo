#!/bin/bash

# usage:
# bash stackrox_scan_image.sh "central-stackrox.apps.example.com:443" "<acs admin token>" "<image url>"

export ROX_CENTRAL_ADDRESS="$1"
export ROX_API_TOKEN="$2"
export IMAGE="$3"
export CVSS_THRESHOLD="7.0"

RC=0

which roxctl > /dev/null  2>&1

if [ $? -ne 0 ]; then
  echo "Could not find roxctl in path."
  echo "Goodbye."
  exit 255
fi

which jq > /dev/null  2>&1

if [ $? -ne 0 ]; then
  echo "Could not find jq in path."
  echo "Goodbye."
  exit 253
fi

echo "*** Scanning Image:<$IMAGE> ***"


data=$(roxctl -e "$ROX_CENTRAL_ADDRESS" -p "$ROX_API_TOKEN" image scan --image "$IMAGE" --insecure-skip-tls-verify)

TOP_CVSS=$(echo "$data" | jq ' .topCvss')
NUM_COMPONENTS=$(echo "$data" | jq -c -r ' .components')

for (( ii=0; ii<$NUM_COMPONENTS; ii++ )); do

  name=$(echo "$data" | jq -c -r .scan.components[$ii] | jq -r '.name')
  version=$(echo "$data" | jq -c -r .scan.components[$ii] | jq -r '.version')
  has_vulns=$(echo "$data" | jq -c -r .scan.components[$ii] | jq -r 'has( "vulns" )')

  if [ "$has_vulns" == "false" ]; then
    continue
  fi

  echo
  echo "Vulnerabilities found!"
  echo "name: $name"
  echo "version: $version"
  echo

  jj=0

  has_more_vulns="true"

  while [ "$has_more_vulns" == "true" ]; do
    cve=$(echo "$data" | jq -c -r .scan.components[$ii] | jq -r .vulns[$jj].cve)
    cvss=$(echo "$data" | jq -c -r .scan.components[$ii] | jq -r .vulns[$jj].cvss)
    summary=$(echo "$data" | jq -c -r .scan.components[$ii] | jq -r .vulns[$jj].summary)
    fixedBy=$(echo "$data" | jq -c -r .scan.components[$ii] | jq -r .vulns[$jj].fixedBy)

    echo "CVE: $cve"
    echo "CVSS: $cvss"
    echo "Summary: $summary"
    echo "FixedBy: $fixedBy"
    echo

    jj=$((jj+1))
    has_more_vulns=$(echo "$data" | jq -c -r .scan.components[$ii].vulns[$jj] | jq -r 'has( "cve" )')

  done
done

echo "Top CVSS Score: $TOP_CVSS"

if (( $(echo "$TOP_CVSS > $CVSS_THRESHOLD"|bc -l) )); then
  echo "Image has a vulnerability with CVSS higher than threshold ($CVSS_THRESHOLD)"
  RC=1
fi

exit $RC

