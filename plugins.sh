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
      cd $plugin && rm -rf * && cd .. && rm -rf $plugin
      echo "$plugin successfully uninstalled"
    fi
  fi
}

function update_plugin {
  local plugin_dir=$1
  cd $1
  git pull origin master 2>/dev/null && echo "Updated $plugin_dir"
}

function check_plugin {
  local dir=$1
  cd $dir
  local local_rev=$(git rev-parse @)
  local remove_rev=$(git rev-parse @{u})
  local base_rev=$(git merge-base @ @{u})

  local base=$(basename `pwd`)
  if [ $local_rev = $remove_rev ]; then
      echo "$base Up to date"
  elif [ $local_rev = $base_rev ]; then
      echo "$base Update available"
  elif [ $remove_rev = $base_rev ]; then
      echo "$base Need to push"
  else
      echo "$base Diverged"
  fi
}

function check {
  if [ -z "${1-}" ]; then
    echo "Error: Unsupported option"
    exit 1
  fi

  local plugin=$1
  if [ "$plugin" == "--all" ]; then
    echo "Checking all"
    cd "$AWSM_PLUGINS_DIR"
    for f in $AWSM_PLUGINS_DIR/*; do
      if [ -d "$f" ]; then
        check_plugin $f
      fi
    done
  else
    local plugin_dir="$AWSM_PLUGINS_DIR/$plugin"
    if [ -d "$plugin_dir" ]; then
      cd "$plugin_dir"
      check_plugin "$plugin_dir"
    else
      echo "Error: no such plugin $plugin"
    fi
  fi
}

function update {
  if [ -z "${1-}" ]; then
    echo "Error: Unsupported option"
    exit 1
  fi

  local plugin=$1
  if [ "$plugin" == "--all" ]; then
    echo "Updating all"
    cd "$AWSM_PLUGINS_DIR"
    for f in $AWSM_PLUGINS_DIR/*; do
      if [ -d "$f" ]; then
        update_plugin $f
      fi
    done
  else
    local plugin_dir="$AWSM_PLUGINS_DIR/$plugin"
    if [ -d "$plugin_dir" ]; then
      cd "$plugin_dir"
      update_plugin "$plugin_dir"
    else
      echo "Error: no such plugin $plugin"
    fi
  fi
}
