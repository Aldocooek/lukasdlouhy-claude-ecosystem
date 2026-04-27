#!/bin/bash
# cost-statusline-fragment.sh
# Returns today's spend from ccusage, formatted for statusline.
# Robust to missing ccusage: returns empty string.

SPEND=$(ccusage 2>/dev/null | grep "^Today:" | awk '{print $2, $3}')

if [ -z "$SPEND" ]; then
  echo ""
else
  echo "Cost: $SPEND"
fi
