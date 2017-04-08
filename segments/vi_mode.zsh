#!/usr/env/bin zsh
# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# VI Mode segments
# This file holds the VI Mode segments for
# the powerlevel9k-ZSH-theme
# https://github.com/bhilburn/powerlevel9k
################################################################

################################################################
# For basic documentation, please refer to the README.md in the top-level
# directory. For more detailed documentation, refer to the project wiki, hosted
# on Github: https://github.com/bhilburn/powerlevel9k/wiki
#
# There are a lot of easy ways you can customize your prompt segments and
# theming with simple variables defined in your `~/.zshrc`.
################################################################

###############################################################
# Vi Mode: show editing mode (NORMAL|INSERT)
set_default "POWERLEVEL9K_VI_INSERT_MODE_STRING" "INSERT"
set_default "POWERLEVEL9K_VI_COMMAND_MODE_STRING" "NORMAL"
# Support visual mode (Requires https://github.com/b4b4r07/zsh-vimode-visual)
set_default "POWERLEVEL9K_VI_VISUAL_MODE_STRING" "VISUAL"
# Parameters:
#   * $1 Alignment: string - left|right
#   * $2 Index: integer
#   * $3 Joined: bool - If the segment should be joined
prompt_vi_mode() {
  local vi_mode
  local current_state
  typeset -gAH vi_states
  vi_states=(
    'NORMAL'      "${DEFAULT_COLOR_INVERTED}"
    'INSERT'      'blue'
    'VISUAL'      'orange'
  )
  case "${KEYMAP}" in
    main|viins)
      current_state="INSERT"
      vi_mode="${POWERLEVEL9K_VI_INSERT_MODE_STRING}"
    ;;
    vicmd)
      current_state="NORMAL"
      vi_mode="${POWERLEVEL9K_VI_COMMAND_MODE_STRING}"
    ;;
    vivis)
      current_state="VISUAL"
      vi_mode="${POWERLEVEL9K_VI_VISUAL_MODE_STRING}"
    ;;
  esac
  serialize_segment "${0}" "${current_state}" "${1}" "${2}" "${3}" "${DEFAULT_COLOR}" "${vi_states[$current_state]}" "${vi_mode}" ''
}

###############################################################
function rebuild_vi_mode {
  if [[ "${POWERLEVEL9K_GENERATOR}" == "async" ]]; then
    if (( ${+terminfo[smkx]} )); then
      printf '%s' ${terminfo[smkx]}
    fi
    for index in $(get_indices_of_segment "vi_mode" "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS}"); do
       prompt_vi_mode "left" "${index}" "${1}" &!
    done
    for index in $(get_indices_of_segment "vi_mode" "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS}"); do
       prompt_vi_mode "right" "${index}" "${1}" &!
    done
  fi
}

###############################################################
# This function returns the correct cursorline
#
# Parameters:
#   * $1 Shape: string - box, hbar or vbar
cursorShape() {
  typeset -gAH CS_konsole # iTerm and yakuake use the same definition
  CS_konsole=(
    "prefix"      "\033]50;CursorShape="
    "box"         "0"
    "vbar"        "1"
    "hbar"        "2"
    "suffix"      "\x7"
  )
  typeset -gAH CS_xterm # tmux uses the same definition
  CS_xterm=(
    "prefix"      "\033["
    "box"         "1"
    "vbar"        "3"
    "hbar"        "5"
    "suffix"      " q"
  )
  typeset -gAH CS_xterm_noblink
  CS_xterm_noblink=(
    "prefix"      "\033["
    "box"         "2"
    "vbar"        "4"
    "hbar"        "6"
    "suffix"      " q"
  )
  typeset -gAH CS_rxvt # gnometerm uses the same definition
  CS_rxvt=(
    "prefix"      "\033["
    "box"         "1"
    "vbar"        "5"
    "hbar"        "3"
    "suffix"      " q"
  )
  typeset -gAH CS_rxvt_noblink
  CS_rxvt_noblink=(
    "prefix"      "\033["
    "box"         "2"
    "vbar"        "6"
    "hbar"        "4"
    "suffix"      " q"
  )
  local cursor_shape_line=""

  case $TERMINAL in
    konsole | iterm | yakuake)
      cursor_shape_line=$CS_konsole[prefix]$CS_konsole[$1]$CS_konsole[suffix]
    ;;
    gnometerm | rxvt | termite | tmux)
      if [[ $POWERLEVEL9K_CURSOR_NOBLINK ]]; then
        cursor_shape_line=$CS_rxvt_noblink[prefix]$CS_rxvt_noblink[$1]$CS_rxvt_noblink[suffix]
      else
        cursor_shape_line=$CS_rxvt[prefix]$CS_rxvt[$1]$CS_rxvt[suffix]
      fi
    ;;
    xterm)
      if [[ $POWERLEVEL9K_CURSOR_NOBLINK ]]; then
        cursor_shape_line=$CS_xterm_noblink[prefix]$CS_xterm_noblink[$1]$CS_xterm_noblink[suffix]
      else
        cursor_shape_line=$CS_xterm[prefix]$CS_xterm[$1]$CS_xterm[suffix]
      fi
    ;;
  esac

  [[ -n $cursor_shape_line ]] && echo -en "$cursor_shape_line"
}

###############################################################
function zle-line-init {
  rebuild_vi_mode "${KEYMAP}"
  # change cursor shape
  if [[ $POWERLEVEL9K_CURSOR_SHAPE ]]; then
    case $KEYMAP in
      vicmd)      cursorShape ${POWERLEVEL9K_CURSOR_SHAPE_NORMAL};;
      viins|main) cursorShape ${POWERLEVEL9K_CURSOR_SHAPE_INSERT};;
      vivis)      cursorShape ${POWERLEVEL9K_CURSOR_SHAPE_VISUAL};;
      *)          cursorShape ${POWERLEVEL9K_CURSOR_SHAPE_DEFAULT};;
    esac
  fi
}

###############################################################
function zle-line-finish {
  rebuild_vi_mode "${KEYMAP}"
  if [[ $POWERLEVEL9K_CURSOR_SHAPE ]]; then
    cursorShape ${POWERLEVEL9K_CURSOR_SHAPE_DEFAULT}
  fi
}

###############################################################
function zle-keymap-select {
  rebuild_vi_mode "${KEYMAP}"
  # change cursor shape
  if [[ $POWERLEVEL9K_CURSOR_SHAPE ]]; then
    case $KEYMAP in
      vicmd)      cursorShape ${POWERLEVEL9K_CURSOR_SHAPE_NORMAL};;
      viins|main) cursorShape ${POWERLEVEL9K_CURSOR_SHAPE_INSERT};;
      vivis)      cursorShape ${POWERLEVEL9K_CURSOR_SHAPE_VISUAL};;
      *)          cursorShape ${POWERLEVEL9K_CURSOR_SHAPE_DEFAULT};;
    esac
  fi
}


###############################################################
function register_zle {
  zle -N zle-line-init
  zle -N zle-line-finish
  zle -N zle-keymap-select
}
register_zle