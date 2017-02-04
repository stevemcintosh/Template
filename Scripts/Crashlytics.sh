#!/bin/sh

echo pwd
External/Infrastructure/Frameworks/Fabric run fa101df80a3cb9460aa4a96ce38e3f9057c962ec f44c7eca066c1db16391164875dcdb6c2eaaeacaebc526e910183575aabd2479

#if [ "$BITRISE_DSYM_PATH" ]; then
#	../Scripts/Crashlytics-Upload-Symbols -a 040dea186f9143cc7732e796b42608634c0afc32 -p ios -d -- "$BITRISE_DSYM_PATH"
#fi
