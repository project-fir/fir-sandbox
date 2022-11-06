#!/bin/bash

origin=`pwd`
cd overrides/packages/elm/virtual-dom/1.0.2
rm -rf elm-stuff
LDEBUG=1 lamdera make --docs="docs.json" # makes sure the package compiles okay
cd ..
#rm pack.zip || true
zip -r pack.zip 1.0.2/ -x "*/.git/*" -x "*/elm-stuff/*"
cd $origin
