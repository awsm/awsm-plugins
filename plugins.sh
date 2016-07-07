: ${AWSM_PLUGINS_HOST_URL='awsm-plugins.s3-website-ap-southeast-2.amazonaws.com/plugins.json'}

function list {
  curl $AWSM_PLUGINS_HOST_URL 2>/dev/null | jq -r -S 'keys | join("\n")'
}

function pad {
  printf '    '
}

function install {
  local plugin=$1
  local source=$(curl $AWSM_PLUGINS_HOST_URL 2>/dev/null | jq -r -S ".\"$plugin\".source")
  if [ -n "$source" ]; then
    echo -e "Installing $plugin from $source"
    cd ~/.awsm/plugins
    if [ -d "$plugin" ]; then
      echo "Error: $plugin already installed"
    else
      git clone $source $plugin
      echo "$plugin successfully installed"
    fi
  fi
}
