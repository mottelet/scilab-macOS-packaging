#!/bin/sh
# validated Thu Nov 26 10:44:49 CET 2020

display() {
printf  "\n[`date +"%H:%M:%S"`] $1\n\n"
}

# Asking for information
# read -p "Enter the version of scilab: "  version
# read -p "Sign the application (yes/no): "  sign
version=branch-6.1
sign=yes

APP="scilab-$version/scilab-$version.app"
JREAPP="scilab-$version/scilab-$version.app/Contents/jre/Scilab JRE Install.app"

if [ $sign == "yes" ]; then
    read -p "Enter the userID: " userID
    read -p "Certificate: " Certificate
    read -p "Password: " passwd

    # Sign Scilab dylibs and jars
    display "Sign Scilab dylibs and jars"
    find $APP/Contents/lib/scilab -type f \( -name "*.dylib"  \) -exec \
        codesign --verbose --force --options runtime --entitlements entitlements.plist --sign "$Certificate" {} \;
    find $APP/Contents/share -type f \( -name "*.jar" \) -exec \
        codesign --verbose --force --options runtime --entitlements entitlements.plist --sign "$Certificate" {} \;

    # Sign thirdparty dylibs and jars
    display "Sign thirdparty dylibs and jars"
    find $APP/Contents/lib/thirdparty -type f \( -name "*.dylib" -or -name "*.jar" \) -exec \
        codesign --verbose --force --options runtime --sign "$Certificate" {} \;
    find $APP/Contents/thirdparty -d 1 -type f \( -name "*.jar" \) -exec \
        codesign --verbose --force --options runtime --sign "$Certificate" {} \;

    # Sign all the scilab executable in bin folder
    display "Sign scilab executables in bin folder"
    find $APP/Contents/bin -type f \( -name "*"  \) -exec \
        codesign --verbose --force --options runtime --entitlements entitlements.plist --sign "$Certificate" {} \;

    # Signing the main app
    display "Sign JRE Install app"
    codesign --strict --verbose --force --options runtime --timestamp --entitlements entitlements.plist -s "$Certificate"  "$JREAPP"


    # Signing the main app
    display "Sign the main app"
    codesign --strict --verbose --force --options runtime --timestamp --entitlements entitlements.plist -s "$Certificate" "$APP"

    # verify signature
    display "Verify signature"
    codesign -vv $APP
    codesign -d --entitlements - "$APP"

    # make the archive
    display "Make the archive"
    rm -f scilab-$version-x86_64.dmg
    helpers/create-dmg/create-dmg --volname scilab-$version --background images/dmg_background.png --window-size 480 414 \
        --icon-size 72 --icon "scilab-$version.app" 125 178 --app-drop-link 351 178 scilab-$version-x86_64.dmg scilab-$version

    # sign the dmg
    display "Sign the archive"
    codesign --verbose -s "$Certificate" --timestamp scilab-$version-x86_64.dmg

    # verify signature
    display "Verify the archive signature"
    codesign -vv scilab-$version-x86_64.dmg

    # notarize
    display "Notarize"
    xcrun altool --notarize-app --primary-bundle-id "scilab-$version" -u $userID -p $passwd -t osx -f scilab-$version-x86_64.dmg

    # check progress
    xcrun altool --notarization-history 0 -u $userID -p $passwd
    # then wait for Apple answer (email  @ developper address)

    read -p "Wait for successfull notarization email from Apple then hit return"

    # staple
    display "Staple the archive"
    xcrun stapler staple scilab-$version-x86_64.dmg
else
    # make the (unsigned) archive
    display "Make the (unsigned) archive"
    rm -f scilab-$version-unsigned-x86_64.dmg
    helpers/create-dmg/create-dmg --volname scilab-$version --background images/dmg_background.png --window-size 480 414 \
        --icon-size 72 --icon "scilab-$version.app" 125 178 --app-drop-link 351 178 scilab-$version-unsigned-x86_64.dmg scilab-$version    
fi

