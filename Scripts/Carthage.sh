#!/bin/sh
echo pwd
if [ ! -d "$SRCROOT/../External/" ]; then
	mkdir "$SRCROOT/../External/"
fi

if [ ! -d "$SRCROOT/../External/Carthage/" ]; then
	cd ../External/ && carthage bootstrap --platform iOS
fi

carthage copy-frameworks
