#
# updated Tue Nov 24 19:22:16 CET 2020
# S. Mottelet
#

Always check that the dependency of libintl.8.dylib w.r.t (GNU) libiconv.2.dylib is the following:

otool -L libintl.8.dylib 
libintl.8.dylib:
	/sw/lib/libintl.8.dylib (compatibility version 10.0.0, current version 10.6.0)
	@loader_path/iconv/libiconv.2.dylib (compatibility version 9.0.0, current version 9.0.0)
	/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (compatibility version 150.0.0, current version 1454.90.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.50.4)

i.e. relative to (GNU) libiconv.2.dylib in the iconv folder. This is necessary in order to prevent /usr/lib/libscups.dylib to load it instead of /usr/lib/libiconv.2.dylib.

If the path is wrong use install_name_tool to change it like this:

$ install_name_tool -change wrong_path @loader_path/iconv/libiconv.2.dylib libintl.8.dylib  


