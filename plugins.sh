set -euo pipefail
: ${AWSM_PLUGINS_HOST_URL='awsm-plugins.s3-website-ap-southeast-2.amazonaws.com/plugins.json'}

function list {
  curl $AWSM_PLUGINS_HOST_URL 2>/dev/null | jq -r -S 'keys | join("\n")'
}

function pad {
  printf '    '
}

function fail {
  local message=$1
  if [ -n "$message" ]; then
    echo $message
  fi
  exit 1
}

function install {
  local plugin=$1
  local source=$(curl $AWSM_PLUGINS_HOST_URL 2>/dev/null | jq -r -S ".\"$plugin\".source")
  if [ -n "$source" ]; then
    echo -e "Installing $plugin from $source"
    cd $AWSM_PLUGINS_DIR
    if [ -d "$plugin" ]; then
      fail "Error: $plugin already installed"
    else
      git clone $source $plugin
      echo "$plugin successfully installed"
    fi
  fi
}

function uninstall {
  local plugin=$1
  if [ -n "$plugin" ]; then
    echo -e "Uninstalling $plugin"
    cd $AWSM_PLUGINS_DIR
    if [ ! -d "$plugin" ]; then
      fail "Error: $plugin not installed"
    else
      rm -r $plugin
      echo "$plugin successfully uninstalled"
    fi
  fi
}
