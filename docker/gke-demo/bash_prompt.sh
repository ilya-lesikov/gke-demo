#!/bin/bash

KUBE_PS1_SEPARATOR=""
KUBE_PS1_PREFIX=" "
KUBE_PS1_SUFFIX=""
KUBE_PS1_CLUSTER_FUNCTION="_prompt_get_cluster"

function _prompt_get_cluster() {
  echo "$1" | rev | cut -d\- -f-2 | rev
}

source "$HOME/.kube-ps1.sh"
PS1='\[\e[32m\]\w\[\e[m\]$(kube_ps1) \[\e[33m\]\\$\[\e[m\] '
