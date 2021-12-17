#!/usr/bin/env ash

DEPS_FILE=$1
if [ ! -f "$DEPS_FILE" ]; then
  echo "Use: cdn-npm.ash cdn-deps.txt"
  exit 1
fi

DEPS_OUT="$DEPS_FILE.cdn-cached"
truncate -s 0 $DEPS_OUT

echo "Cache CDN from dependencies in '$DEPS_FILE'"
echo "Output Cached CDN dependencies in '$DEPS_OUT'"

if [ -z "$ROOT_CDN" ]; then ROOT_CDN="`pwd`/cdn" ; fi
if [ -z "$ROOT_PKG" ]; then ROOT_PKG="`pwd`/pkg" ; fi

mkdir -p "$ROOT_PKG" "$ROOT_CDN"

cdn_npm_pkg() {
  PKG=$1
  PKG_TAR="$ROOT_PKG/$PKG.tgz"

  echo
  if [ ! -f "$PKG_TAR" ] ; then
    echo "PKG '$PKG' discovery"
    PKG_ID=$(npm pack --json --dry-run $PKG | npx fx '.[0].id')

    if [ "$PKG" != "$PKG_ID" ]; then
      echo "CDN PKG '$PKG' should be '$PKG_ID' fully specified"
      PKG=$PKG_ID
      PKG_TAR="$ROOT_PKG/$PKG.tgz"
    fi
  fi

  if [ -f "$PKG_TAR" ] ; then
    echo "PKG '$PKG' exists :: '$PKG_TAR'"
  else
    echo "PKG '$PKG' downloading :: '$PKG_TAR'"

    PACK_FILE=$(npm pack $PKG --pack-destination=$ROOT_PKG)

    # use our naming scheme
    mkdir -p `dirname "$PKG_TAR"`
    mv "$ROOT_PKG/$PACK_FILE" "$PKG_TAR"
    echo "PKG '$PKG' completed downloading :: '$PKG_TAR'"
  fi

  PKG_CDN="$ROOT_CDN/$PKG/"
  if [ -f "$PKG_CDN/package.json" ] ; then
    echo "CDN '$PKG' exists :: '$PKG_CDN'"
  else
    echo "CDN '$PKG' extracting :: '$PKG_CDN'"
    mkdir -p "$PKG_CDN"
    tar xof "$PKG_TAR" -C "$PKG_CDN" --strip-components 1
    echo "CDN '$PKG' completed extraction :: '$PKG_CDN'"
  fi

  echo "$PKG" >> $DEPS_OUT
  echo
}

while read PKG; do
  if [ -n "$PKG" ] ; then
    cdn_npm_pkg $PKG
  fi
done < $DEPS_FILE

echo "Output Cached CDN dependencies in '$DEPS_OUT'"

