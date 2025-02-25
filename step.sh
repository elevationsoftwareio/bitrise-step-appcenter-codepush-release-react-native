#!/bin/bash
set -ex

# Ensure CodePush Standalone installed
if which code-push-standalone > /dev/null; then
  echo "CodePush CLI already installed."
else
  cd ..
  echo "CodePush CLI is not installed. Installing..."
  git clone https://github.com/microsoft/code-push-server code-push-server
  cd code-push-server/cli
  npm install
  npm run build
  npm install -g
fi

echo "Testing CodePush CLI"
code-push-standalone --version

# if no api token is provided, return an error
if [ -z "${api_token}" ] ; then
    echo " [!] Missing required input: api_token"
    exit 0
fi

echo "Authenticating with CodePush"
code-push-standalone login --key $api_token https://apps.deploypulse.io

cd "$BITRISE_SOURCE_DIR"


# Change the working dir if necessary
if [ ! -z "${react_native_project_root}" ] ; then
    echo "==> Switching to react native project root: ${react_native_project_root}"
    cd "${react_native_project_root}"
    if [ $? -ne 0 ] ; then
        echo " [!] Failed to switch to react native project root: ${react_native_project_root}"
        exit 1
    fi
fi

# install dependencies
if [ -e "package.json" ]; then
    echo "==> Installing node modules"
    npm install
fi

code-push-standalone release-react "${app_id}" $platform --quiet --description "${description}" --deployment-name $deployment --rollout $percentage --targetBinaryVersion "${target_binary_version}" $private_key $options

exit 0
