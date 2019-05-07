#!/bin/bash

if git log -1 --pretty=oneline | grep -v 'Version auto-incremented'
then
    echo "Building release"
    node increment_version.js
    git commit -a -m "Version auto-incremented  - $TRAVIS_JOB_NUMBER [ci skip]"
    gulp build
    gulp release
    git remote add github https://token@github.com/xmorave2/koha-plugin-availabilityapi
    git fetch --all
    git push github HEAD:master
else
  echo "No release needing."
fi
