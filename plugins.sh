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
  local source_name=awsm-$plugin
  local source=$(curl $AWSM_PLUGINS_HOST_URL 2>/dev/null | jq -r -S ".\"$plugin\".source")
  if [ -n "$source" ]; then
    echo -e "Installing $plugin from $source"
    cd $AWSM_PLUGINS_DIR
    if [ -d "$source_name" ]; then
      fail "Error: $plugin already installed"
    else
      git clone $source $source_name
      echo "$plugin successfully installed"
    fi
  fi
}

function uninstall {
  local plugin=$1
  local source_name=awsm-$plugin
  if [ -n "$plugin" ]; then
    echo -e "Uninstalling $plugin"
    cd $AWSM_PLUGINS_DIR
    if [ ! -d "$source_name" ]; then
      fail "Error: $plugin not installed"
    else
      cd $source_name && rm -rf * && cd .. && rm -rf $source_name
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
  local plugin=${base#awsm-}
  if [ $local_rev = $remove_rev ]; then
      echo "$plugin is up to date"
  elif [ $local_rev = $base_rev ]; then
      echo "$plugin has update available"
  elif [ $remove_rev = $base_rev ]; then
      echo "$plugin need to be pushed"
  else
      echo "$plugin has diverged"
  fi
}

function check {
  if [ -z "${1-}" ]; then
    echo "Error: Unsupported option"
    exit 1
  fi

  local plugin=$1
  local source_name=awsm-$plugin

  if [ "$plugin" == "--all" ]; then
    echo "Checking all"
    cd "$AWSM_PLUGINS_DIR"
    for f in $AWSM_PLUGINS_DIR/*; do
      if [ -d "$f" ]; then
        check_plugin $f
      fi
    done
  else
    local plugin_dir="$AWSM_PLUGINS_DIR/$source_name"
    if [ -d "$plugin_dir" ]; then
      cd "$plugin_dir"
      check_plugin "$plugin_dir"
    else
      echo "Error: $plugin not found"
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
