#!/bin/bash

shopt -s globstar

# Check script options
if [[ "$#" -lt 1 ]]; then
    echo "Usage: ./init.sh MyAddonName [folder]"
    exit 1
fi

if [[ $(echo "$1" | head -c 1) == "-" ]]; then
    echo "Usage: ./init.sh MyAddonName [folder]"
    exit 1
fi

# Check script necessary tools : sed, perl, perl-rename
PERL=$(command -v perl)
if [[ ! -x "$PERL" ]] ; then
  echo "Install perl"
  exit 1
fi

RENAME=$(command -v perl-rename)
if [[ ! -x "$RENAME" ]] ; then
  RENAME=$(command -v rename)
fi

# Probe rather than read --help: Homebrew's rename takes the same perl
# expression as perl-rename but never prints PERLEXPR, so parsing the help text
# rejects a tool that would have worked.
RENAME_PROBE=$(mktemp -d)
: > "$RENAME_PROBE/probe_a"
( cd "$RENAME_PROBE" && "$RENAME" 's/probe_a/probe_b/' probe_a ) >/dev/null 2>&1
if [[ ! -e "$RENAME_PROBE/probe_b" ]]; then
  rm -rf "$RENAME_PROBE"
  echo "Install perl-rename (sometimes called just 'rename')"
  exit 1
fi
rm -rf "$RENAME_PROBE"

SED=/usr/bin/sed
if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! [[ -x "$(command -v gsed)" ]]; then
    echo "Install gnu-sed"
    exit 1
  fi
  SED=$(command -v gsed)
fi


ADDON="$1"
ADDON_LC=$(echo $ADDON | $PERL -ne 'print lc')
ADDON_LC_DASHES=$(echo $ADDON_LC | sed 's/_/-/g')

ADDON_DIR="$PWD"

if [[ "x$2" != "x" ]]; then
  TARGET_FOLDER="$2"
  mkdir -p "$TARGET_FOLDER"
  cp -rf * "$TARGET_FOLDER/"
  cd "$TARGET_FOLDER"
else
  TARGET_FOLDER="$PWD"
fi

mv "MyVfx" "$ADDON"
# `shopt -s globstar` is a no-op on bash 3.2, which is still /bin/bash on macOS,
# so `**/` matched one directory level and silently skipped every top-level file
# -- CMakeLists.txt and the add-on's own sources among them. Walk with find.
tpl_sources() {
  find . -type f \( -name '*.hpp' -o -name '*.cpp' -o -name '*.txt' \) -not -path './.git/*'
}

tpl_sources | tr '\n' '\0' | xargs -0 $RENAME "s/my_vfx/$ADDON_LC/"
tpl_sources | tr '\n' '\0' | xargs -0 $RENAME "s/MyVfx/$ADDON/"

find . -type f \( -name '*.hpp' -o -name '*.cpp' -o -name '*.txt' -o -name '*.json' \) \
     -not -path './.git/*' | tr '\n' '\0' \
  | xargs -0 $SED -i "s/my_vfx/$ADDON_LC/g;s/MyVfx/$ADDON/g;s/my-vfx/$ADDON_LC_DASHES/g"
[ -f release.sh ] && $SED -i "s/MyVfx/$ADDON/g;s/my-vfx/$ADDON_LC_DASHES/g" release.sh

# addon.json also carries the placeholder as a display name, which no rename
# above touches.
$SED -i "s/My VFX/$ADDON/g" addon.json

echo -e "# $ADDON\nA new and wonderful [ossia score](https://ossia.io) add-on" > README.md


# One uuid for the whole add-on: score matches localaddon.json's "key" against the
# PLUGIN_UUID compiled into the plug-in, and rejects the add-on if they differ.
ADDON_UUID=$(uuidgen)
find . \( -name '*.hpp' -o -name '*.cpp' -o -name '*.json' -o -name '*.txt' \) \
  -exec $PERL -pi -e "s|00000000-0000-0000-0000-000000000000|$ADDON_UUID|gi" {} \;
