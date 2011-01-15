require 'mkmf'
require 'rbconfig'
include Config

if (CONFIG["host_os"] == "mswin32" )
	$LOCAL_LIBS += "swelib32.lib"
else
	$LOCAL_LIBS += "libswe.a"
end

dir_config("sweph4ruby")
create_makefile("sweph4ruby")
