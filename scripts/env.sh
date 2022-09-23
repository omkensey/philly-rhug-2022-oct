#!/bin/bash

i=0
varlist=( $(compgen -e) )
listlen=${#varlist[*]}
echo "{"
for var in ${varlist[*]}; do
  value=$(echo "${!var}" | sed -e 's/\n//')
  echo -n \"$var\": \"$value\"
  let i=$i+1
  if [[ $i -lt $listlen ]]; then
    echo ","
  fi
done
echo -e "\n}"
