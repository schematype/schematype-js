#!/bin/bash

set -e -o pipefail

# : ${GITHUB_AUTH_TOKEN:?}

orgs=(
  18F
  ActiveState
  HelionDevPlatform
  IBM-Bluemix
  Stackato-Apps
  appfog
  cf-platform-eng
  cloud-native-java
  cloudancy
  cloudfoundry
  cloudfoundry-attic
  cloudfoundry-community
  cloudfoundry-incubator
  cloudfoundry-samples
  codeship
  curtispd
  digitalfinesse
  dwong-pivotal
  europeana
  gitrepository
  hpcloud
  ibm-bluemix-mobile-services
  ibm-cds-labs
  paasio
  pivotal-cf
  pivotal-education
  starkandwayne
  steerapi
  watson-developer-cloud
)

(
  for org in ${orgs[@]}; do
    page=1
    while true; do
      # sleep 2               # Authed users only allowed 30 requests per minute.
      sleep 6               # Un-authed users only allowed 10 requests per minute.

#         --header "Authorization: token $GITHUB_AUTH_TOKEN" \

      curl --request GET \
        "https://api.github.com/search/code?q=name+filename:manifest.yml+user:$org;per_page=100;page=$page" \
        --user-agent curl \
        --silent |
      grep '"html_url":.*/manifest\.yml"' |
      cut -d'"' -f4 |
      sed 's/^https:\/\/github\.com\///' ||
        break
      page=$((page + 1))
    done
  done
) | (
  while read line; do
    line=${line//\/\//\/}
    line2=${line%/manifest.yml}
    set -- $(IFS='/'; echo $line2)
    org=$1
    repo=$2
    sha=$4
    shift;shift;shift;shift
    path=$(IFS='/'; echo "$*")

    url="https://raw.githubusercontent.com/$org/$repo/$sha"
    [[ -n $path ]] && url+="/$path"
    url+="/manifest.yml"
    dir="files/$org/$repo/$path"
    dir=${dir%%/}
    file="$dir/manifest.yml"

    mkdir -p $dir
    (
      # if [[ -f $file ]]; then
      #   cp $file $file2
      # else
        set -x
        curl -s "$url" > "$file"
      # fi
    )
  done
)
