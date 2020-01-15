#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

tgfiles="$(find "$SCRIPT_DIR/terraform/environments" -name terragrunt.hcl \
  ! -path "*/.terragrunt-cache/*" | tr '\n' ' ')"

for tgfile in $tgfiles; do
  cd "$(dirname "$tgfile")"
  terragrunt init -input=false || true
done


# | \
#   xargs dirname | xargs -I $(cd 
