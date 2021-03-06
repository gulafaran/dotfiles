### .profile

##less
export LESS=-R
export LESS_TERMCAP_mb=$'\e[01;31m'
export LESS_TERMCAP_md=$'\e[01;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;32m'

#XDG base dir plz
eval $(dircolors "$XDG_CONFIG_HOME"/dircolors)

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec systemd-cat /usr/bin/sx
fi

if [[ ! $DISPLAY && $XDG_VTNR -eq 2 ]]; then
  source /home/tom/.config/wayland/envvars
  exec sway --unsupported-gpu
fi
