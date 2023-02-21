#!/bin/bash

VERSION=""

# Get parameters
while getopts v: flag
do
  case "${flag}" in
    v) VERSION=${OPTARG};;
  esac
done

# Get the current highest tag number, add the first v0.1.0 tag if there are none
git fetch --prune --unshallow 2>/dev/null
CURRENT_VERSION=`git describe --abbrev=0 --tags 2>/dev/null`

if [[ $CURRENT_VERSION == '' ]]
then
  CURRENT_VERSION='v0.1.0'
fi
echo "Current Version: $CURRENT_VERSION"

# Replace . with a space so can split into an array
CURRENT_VERSION_PARTS=(${CURRENT_VERSION//./ })

# Get the SEMVER major/minor/patch numbers
VNUM1=${CURRENT_VERSION_PARTS[0]}
VNUM2=${CURRENT_VERSION_PARTS[1]}
VNUM3=${CURRENT_VERSION_PARTS[2]}

if [[ $VERSION == 'major' ]]
then
  VNUM1=v$((VNUM1+1))
elif [[ $VERSION == 'minor' ]]
then
  VNUM2=$((VNUM2+1))
elif [[ $VERSION == 'patch' ]]
then
  VNUM3=$((VNUM3+1))
else
  echo "No version type (https://semver.org/) or incorrect type specified, try: -v [major, minor, patch]"
  exit 1
fi

# Create a new SEMVER Git Tag
NEW_TAG="$VNUM1.$VNUM2.$VNUM3"
echo "($VERSION) updating $CURRENT_VERSION to $NEW_TAG"

# Get the current commit hash and see if it is already tagged
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`

# Only create a new Tag if one is needed
if [ -z "$NEEDS_TAG" ]; then
  echo "Tagged with $NEW_TAG"
  git tag $NEW_TAG
  git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$GITHUB_REPO.git --tags
  git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$GITHUB_REPO.git
else
  echo "A tag already exists for this commit."
fi

echo ::set-output name=git-tag::$NEW_TAG

exit 0