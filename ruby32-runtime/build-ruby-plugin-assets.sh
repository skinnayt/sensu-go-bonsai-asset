#!/bin/bash
##
# General asset build script
##
[[ -z "$WDIR" ]] && { echo "WDIR is empty using bonsai/" ; WDIR="bonsai/"; }

[[ -z "$GITHUB_TOKEN" ]] && { echo "GITHUB_TOKEN is empty" ; exit 1; }
[[ -z "$1" ]] && { echo "Parameter 1, GEM_NAME is empty" ; exit 1; }
[[ -z "$2" ]] && { echo "Parameter 2, GIT_OWNER_REPO is empty" ; exit 1; }
[[ -z "$3" ]] && { echo "Parameter 3, GIT_REF is empty" ; exit 1; }

GEM_NAME=$1
GIT_OWNER_REPO=$2
GIT_REF=$3
GITHUB_RELEASE_TAG=$4
TAG=$GITHUB_RELEASE_TAG
[[ -z "$TAG" ]] && { echo "GITHUB_RELEASE_TAG is empty" ; TAG="0.0.1"; }
echo $GEM_NAME $GIT_OWNER_REPO $TAG $GIT_REF

mkdir dist
GIT_REPO="https://github.com/${GIT_OWNER_REPO}.git"

platforms=( almalinux9 amzn2 debian12 gentoo2.17 )
ruby_version=3.2.0
runtime_version=0.3.0
if [ -d dist ]; then
  for platform in "${platforms[@]}"; do

    for ARCH in amd64 arm64; do
      ruby_plugin_image="ruby-${ruby_version}-plugin-${platform}-${ARCH}"

      EMULARCH=""

      if [ ${ARCH} == "arm64" ]; then
        EMULARCH="-v /usr/bin/qemu-aarch64:/usr/bin/qemu-aarch64"
      fi

      echo docker build --platform linux/${ARCH} --build-arg MY_RUNTIME_IMAGE=registry.docker.skinnayt.ca:5000/sensu-ruby-runtime-${ruby_version}-${platform}-${ARCH}:${runtime_version} --build-arg BUILD_ARCH=${ARCH} --build-arg "ASSET_GEM=${GEM_NAME}" --build-arg "GIT_REPO=${GIT_REPO}"  --build-arg "GIT_REF=${GIT_REF}" -t ${ruby_plugin_image} --load -f ${WDIR}/ruby32-runtime/Dockerfile.${platform} .
      docker buildx build --platform linux/${ARCH} --build-arg MY_RUNTIME_IMAGE=registry.docker.skinnayt.ca:5000/sensu-ruby-runtime-${ruby_version}-${platform}-${ARCH}:${runtime_version} --build-arg BUILD_ARCH=${ARCH} --build-arg "ASSET_GEM=${GEM_NAME}" --build-arg "GIT_REPO=${GIT_REPO}"  --build-arg "GIT_REF=${GIT_REF}" -t ${ruby_plugin_image} --load -f ${WDIR}/ruby32-runtime/Dockerfile.${platform} .
      status=$?
      if test $status -ne 0; then
            echo "Docker build for platform: ${platform} failed with status: ${status}"
            exit 1
      fi

      # docker cp ${EMULARCH} --platform linux/${ARCH} $(docker create --platform linux/${ARCH} --rm ${ruby_plugin_image}:latest sleep 0):/${GEM_NAME}.tar.gz ./dist/${GEM_NAME}_${TAG}_${platform}_linux_${ARCH}.tar.gz
      echo docker cp \$\(docker create --platform linux/${ARCH} --rm ${ruby_plugin_image}:latest sleep 0\):/${GEM_NAME}.tar.gz ./dist/${GEM_NAME}_${TAG}_ruby-${ruby_version}_${platform}_linux_${ARCH}.tar.gz
      docker cp $(docker create --platform linux/${ARCH} --rm ${ruby_plugin_image}:latest sleep 0):/${GEM_NAME}.tar.gz ./dist/${GEM_NAME}_${TAG}_ruby-${ruby_version}_${platform}_linux_${ARCH}.tar.gz
      status=$?
      if test $status -ne 0; then
            echo "Docker cp for platform: ${platform} failed with status: ${status}"
      fi
    done
  done

  # Generate the sha512sum for all the assets
  files=$( ls dist/*.tar.gz )
  echo $files
  for filename in $files; do
    if [[ "$GITHUB_RELEASE_TAG" ]]; then
      echo "upload $filename"
      #${WDIR}/github-release-upload.sh github_api_token=$GITHUB_TOKEN repo_slug="$GIT_OWNER_REPO" tag="${GITHUB_RELEASE_TAG}" filename="$filename"
    fi
  done 
  file=$(basename "${files[0]}")
  IFS=_ read -r package leftover <<< "$file"
  unset leftover
  if [ -n "$package" ]; then
    echo "Generating sha512sum for ${package}"
    cd dist || exit
    sha512_file="${package}_${TAG}_sha512-checksums.txt"
    #echo "${sha512_file}" > sha512_file
    echo "sha512_file: ${sha512_file}"
    sha512sum ./*.tar.gz > "${sha512_file}"
    echo ""
    cat "${sha512_file}"
    cd ..
    if [[ "$GITHUB_RELEASE_TAG" ]]; then
      echo "upload ${sha512_file}"
      #${WDIR}/github-release-upload.sh github_api_token=$GITHUB_TOKEN repo_slug="$GIT_OWNER_REPO" tag="${GITHUB_RELEASE_TAG}" filename="dist/${sha512_file}"
    fi
  fi

  # Generate github release edit event 
  #${WDIR}/github-release-event.sh github_api_token=$GITHUB_TOKEN repo_slug="$GIT_OWNER_REPO" tag="${GITHUB_RELEASE_TAG}" 
  echo ${WDIR}/sensu-generate-asset-file.rb -n ${GEM_NAME} -N ${GIT_OWNER_REPO%%/*} -V ${TAG} -u ${BASE_URL} -r ${ruby_version} -a $(echo "${GEM_NAME}" | sed -e 's/^sensu-plugins/sensu-plugins-ruby32/') \| tee dist/asset-${GEM_NAME}_${TAG}.yaml
  ${WDIR}/sensu-generate-asset-file.rb -n ${GEM_NAME} -N ${GIT_OWNER_REPO%%/*} -V ${TAG} -u ${BASE_URL} -r ${ruby_version} -a $(echo "${GEM_NAME}" | sed -e 's/^sensu-plugins/sensu-plugins-ruby32/') | tee dist/asset-${GEM_NAME}_${TAG}.yaml

else
  echo "error dist directory is missing"
fi

