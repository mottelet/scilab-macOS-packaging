#!/bin/sh
#
# updated Tue Nov 24 19:16:54 CET 2020
#
# prior to this make install in build directory !
# prefix should be Scilab.app/Contents
#

display() {
printf  "[`date +"%H:%M:%S"`] $1\n"
}

version=branch-6.1

# copy Scilab application files
display "Copy Scilab application files"
rm -rf scilab-$version.tgz
rm -rf scilab-$version/
mkdir scilab-$version

APP=scilab-$version/scilab-$version.app

cp -Pa Scilab.app $APP
find $APP -type f -name ".DS_Store" -exec rm -f "{}" \;
find $APP -type d -name ".svn" -exec rm -rf "{}" \;

# fix dependencies in binaries
display "fix dependencies in binaries"
helpers/fix_scilab_lib_paths $APP/Contents/bin/scilab-bin
helpers/fix_scilab_lib_paths $APP/Contents/bin/scilab-cli-bin
helpers/fix_scilab_lib_paths $APP/Contents/bin/modelicac
helpers/fix_scilab_lib_paths $APP/Contents/bin/modelicat
helpers/fix_scilab_lib_paths $APP/Contents/bin/XML2modelica

# fix dependencies in scilab libraries
display "Fix dependencies in scilab libraries"
dylibs=`find $APP/Contents/lib/scilab -name '*.dylib' -type f`
for dylib in $dylibs; do
  install_name_tool -id `basename $dylib` $dylib
  helpers/fix_scilab_lib_paths $dylib
done

# patch scilab script
display "Patch scilab script"
patch $APP/Contents/bin/scilab patches/scilab.patch

# copy thirdparty, include, libs/thirdparty and share/scilab/etc/classpath.xml
display "Copy thirdparty, include, libs/thirdparty and share/scilab/etc/classpath.xml"
rm -rf $APP/lib/thirdparty/ $APP/thirdparty/
cp -fPa Contents/* $APP/Contents/

# Main executable
mkdir -p  $APP/Contents/MacOS
cp $APP/Contents/bin/scilab $APP/Contents/MacOS
cd $APP/Contents/MacOS
ln -s ../bin/scilab-bin .
cd ../../../../

# Make tgz archive
display "Make tgz archive"
tar czf scilab-$version.tgz  scilab-$version
display "Done."

