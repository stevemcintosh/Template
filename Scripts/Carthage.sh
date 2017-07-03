#!/bin/sh
echo pwd
if [ ! -d "$SRCROOT/../External/" ]; then
	mkdir "$SRCROOT/../External/"
	cd ../External/ && carthage bootstrap --platform iOS
else
	cd ../External/ && carthage update --platform iOS
fi

carthage copy-frameworks
