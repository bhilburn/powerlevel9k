#!/usr/bin/env zsh
# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# @title powerlevel9k Theme
# @source https://github.com/bhilburn/powerlevel9k
##
# @authors
#   Ben Hilburn
#   Dominik Ritter
##
# @info
#   This theme was inspired by [agnoster's Theme](https://gist.github.com/3712874)
#
#   For basic documentation, please refer to the README.md in the top-level
#   directory. For more detailed documentation, refer to the
#   [project wiki](https://github.com/bhilburn/powerlevel9k/wiki).
#
#   There are a lot of easy ways you can customize your prompt segments and
#   theming with simple variables defined in your `~/.zshrc`. Please refer to
#   the `sample-zshrc` file for more details.
################################################################

## Turn on for Debugging
#PS4='%s%f%b%k%F{blue}%{λ%}%L %F{240}%N:%i%(?.. %F{red}%?) %1(_.%F{yellow}%-1_ .)%s%f%b%k '
#zstyle ':vcs_info:*+*:*' debug true
#set -o xtrace

# Try to set the installation path
if [[ -n "$P9K_INSTALLATION_DIR" ]]; then
  p9kDirectory=${P9K_INSTALLATION_DIR:A}
else
  if [[ "${(%):-%N}" == '(eval)' ]]; then
    if [[ "$0" == '-antigen-load' ]] && [[ -r "${PWD}/powerlevel9k.zsh-theme" ]]; then
      # Antigen uses eval to load things so it can change the plugin (!!)
      # https://github.com/zsh-users/antigen/issues/581
      p9kDirectory=$PWD
    else
      print -P "%F{red}You must set P9K_INSTALLATION_DIR to work from within an (eval).%f"
      return 1
    fi
  else
    # Get the path to file this code is executing in; then
    # get the absolute path and strip the filename.
    # See https://stackoverflow.com/a/28336473/108857
    p9kDirectory=${${(%):-%x}:A:h}
  fi
fi

################################################################
# Source utility functions
################################################################

source "${p9kDirectory}/functions/utilities.zsh"

################################################################
# Source icon functions
################################################################

source "${p9kDirectory}/functions/icons.zsh"

################################################################
# Source color functions
################################################################

source "${p9kDirectory}/functions/colors.zsh"

################################################################
# Color Scheme
################################################################

if [[ "$P9K_COLOR_SCHEME" == "light" ]]; then
  DEFAULT_COLOR=white
  DEFAULT_COLOR_INVERTED=black
else
  DEFAULT_COLOR=black
  DEFAULT_COLOR_INVERTED=white
fi

################################################################
# Deprecated segments and variables
################################################################

# Display a warning if deprecated segments are in use.
typeset -AH deprecated_segments
# old => new
deprecated_segments=(
  'longstatus'      'status'
)
printDeprecationWarning deprecated_segments

# Display a warning if deprecated variables have been updated.
typeset -AH deprecated_variables
# old => new
deprecated_variables=(
  # status icons
  'P9K_OK_ICON'                 'P9K_STATUS_OK_ICON'
  'P9K_FAIL_ICON'               'P9K_STATUS_ERROR_ICON'
  'P9K_CARRIAGE_RETURN_ICON'    'P9K_STATUS_ERROR_CR_ICON'
  # aws_eb_env segment
  'P9K_AWS_EB_ICON'             'P9K_AWS_EB_ENV_ICON'
  # command_execution_time segment
  'P9K_EXECUTION_TIME_ICON'     'P9K_COMMAND_EXECUTION_TIME_ICON'
  # dir segment
  'P9K_HOME_ICON'               'P9K_DIR_HOME_ICON'
  'P9K_HOME_SUB_ICON'           'P9K_DIR_HOME_SUBFOLDER_ICON'
  'P9K_FOLDER_ICON'             'P9K_DIR_DEFAULT_ICON'
  'P9K_LOCK_ICON'               'P9K_DIR_NOT_WRITABLE_ICON'
  'P9K_ETC_ICON'                'P9K_DIR_ETC_ICON'
  # disk_usage segment
  'P9K_DISK_ICON'               'P9K_DISK_USAGE_NORMAL_ICON,P9K_DISK_USAGE_WARNING_ICON,P9K_DISK_USAGE_CRITICAL_ICON'
  # docker_machine segment
  'P9K_SERVER_ICON'             'P9K_DOCKER_MACHINE_ICON'
  # host segment
  'P9K_HOST_ICON'               'P9K_HOST_LOCAL_ICON,P9K_HOST_REMOTE_ICON'
  # ip segment
  'P9K_NETWORK_ICON'            'P9K_IP_ICON'
  # go_version segment
  'P9K_GO_ICON'                 'P9K_GO_VERSION_ICON'
  # kubecontext segment
  'P9K_KUBERNETES_ICON'         'P9K_KUBECONTEXT_ICON'
  # load segment
  'P9K_LOAD_ICON'               'P9K_LOAD_NORMAL_ICON,P9K_LOAD_WARNING_ICON,P9K_LOAD_CRITICAL_ICON'
  # node_env and node_version segments
  'P9K_NODE_ICON'               'P9K_NODE_ENV_ICON,P9K_NODE_VERSION_ICON'
  # pyenv segment
  'P9K_PYTHON_ICON'             'P9K_PYENV_ICON'
  # rbenv segment
  'P9K_RUBY_ICON'               'P9K_RBENV_ICON'
  # rust segment
  'P9K_RUST_ICON'               'P9K_RUST_VERSION_ICON'
  # swift_version segment
  'P9K_SWIFT_ICON'              'P9K_SWIFT_VERSION_ICON'
  # user segment
  'P9K_USER_ICON'               'P9K_USER_DEFAULT_ICON'
  'P9K_ROOT_ICON'               'P9K_USER_ROOT_ICON'
  'P9K_SUDO_ICON'               'P9K_USER_SUDO_ICON'
  # vi_mode segment
  'P9K_VI_INSERT_MODE_STRING'   'P9K_VI_MODE_INSERT_ICON'
  'P9K_VI_NORMAL_MODE_STRING'   'P9K_VI_MODE_NORMAL_ICON'
  'P9K_VI_VISUAL_MODE_STRING'   'P9K_VI_MODE_VISUAL_ICON'
)
printDeprecationVarWarning deprecated_variables

################################################################
# Choose the generator
################################################################

case "${(L)P9K_GENERATOR}" in
  "zsh-async")
    source "${p9kDirectory}/generator/zsh-async.p9k"
  ;;
  *)
    source "${p9kDirectory}/generator/default.p9k"
  ;;
esac

################################################################
# Load Prompt Segment Definitions
################################################################

# load only the segments that are being used!
local segmentName
typeset -gU loadedSegments
for segment in $p9kDirectory/segments/*.p9k; do
  segmentName=${${segment##*/}%.p9k}
  if segmentInUse "$segmentName"; then
    source "${segment}" 2>&1
    loadedSegments+=("${segmentName}")
  fi
done

# cleanup temporary variable - not done because it is used for autoloading segments
#unset p9kDirectory

# Launch the generator
prompt_powerlevel9k_setup "$@"
