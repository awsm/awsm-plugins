AWSM_PLUGINS_SOURCE_FILE=$(realpath ${BASH_SOURCE[0]})
AWSM_PLUGINS_SOURCE_DIR=$(realpath `dirname ${AWSM_PLUGINS_SOURCE_FILE}`/)

function plugins {
  source $AWSM_PLUGINS_SOURCE_DIR/plugins.sh
  $@
}
