class Tdb < Formula
  desc "Trivial Database (TDB): simplest database API"
  homepage "https://tdb.samba.org/"
  url "https://www.samba.org/ftp/tdb/tdb-1.3.16.tar.gz"
  sha256 "6a3fc2616567f23993984ada3cea97d953a27669ffd1bfbbe961f26e0cf96cc5"

  depends_on "docbook-xsl" => :build
  depends_on "pkg-config" => :build
  depends_on "python@2" => :build

  # Patch is to add version info to libdtb.dynlib, things will work without it,
  # but upstream does attempt to set it but is broken. Also, patch prevents
  # the Python extension from being linked against the Python library to
  # comply with the Homebrew policy (as notified by audit).
  # Patch submitted as PR #203 upstream.
  patch :DATA

  def install
    # Disabling of RPATH is crucial, because otherwise apps link against the
    # resulting libtdb.dynlib but fail at runtime because they go looking for
    # libtdb.inst.dynlib, which is a consequence of the rpath-related code in
    # the upstream build system.
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-rpath",
                          "--disable-rpath-install",
                          "--disable-rpath-private-install",
                          "--prefix=#{prefix}"
    system "make", "check", "install"
  end

  test do
    # The pipe doesn't work with default shell (invoked as 'sh'), so invoke bash
    system "bash", "-c", "echo -e 'create testdb' | #{bin}/tdbtool"
    system "bash", "-c", "echo -e 'open testdb\\ninsert xyz 123' | #{bin}/tdbtool"
    system "bash", "-c", "echo -e 'open testdb\\ninfo' | #{bin}/tdbtool | grep 'Number of records' | cut -d':' -f 2 | xargs test 1 ="
    system "bash", "-c", "echo -e 'open testdb\\ndelete xyz' | #{bin}/tdbtool"
    system "bash", "-c", "echo -e 'open testdb\\ninfo' | #{bin}/tdbtool | grep 'Number of records' | cut -d':' -f 2 | xargs test 0 ="
  end
end

__END__
diff --git a/buildtools/wafsamba/wafsamba.py b/buildtools/wafsamba/wafsamba.py
index 12d5421..3e56d29 100644
--- a/buildtools/wafsamba/wafsamba.py
+++ b/buildtools/wafsamba/wafsamba.py
@@ -1018,6 +1018,24 @@ def apply_bundle_remove_dynamiclib_patch(self):
         if not getattr(self,'vnum',None):
             try:
                 self.env['LINKFLAGS'].remove('-dynamiclib')
+
+                # Only try to remove these if -dynamiclib was preset, i.e. no exception above
+                try:
+                    arg_idx = self.env['LINKFLAGS'].index('-compatibility_version')
+                    self.env['LINKFLAGS'].pop(arg_idx) # the argument
+                    self.env['LINKFLAGS'].pop(arg_idx) # the subargument
+                except ValueError:
+                    pass
+                try:
+                    arg_idx = self.env['LINKFLAGS'].index('-current_version')
+                    self.env['LINKFLAGS'].pop(arg_idx) # the argument
+                    self.env['LINKFLAGS'].pop(arg_idx) # the subargument
+                except ValueError:
+                    pass
+            except ValueError:
+                pass
+
+	    try:
                 self.env['LINKFLAGS'].remove('-single_module')
             except ValueError:
                 pass
diff --git a/third_party/waf/wafadmin/Tools/gcc.py b/third_party/waf/wafadmin/Tools/gcc.py
index 83d5b24..8fc1930 100644
--- a/third_party/waf/wafadmin/Tools/gcc.py
+++ b/third_party/waf/wafadmin/Tools/gcc.py
@@ -94,8 +94,8 @@ def gcc_modifier_cygwin(conf):
 @conftest
 def gcc_modifier_darwin(conf):
 	v = conf.env
-	v['shlib_CCFLAGS']       = ['-fPIC', '-compatibility_version', '1', '-current_version', '1']
-	v['shlib_LINKFLAGS']     = ['-dynamiclib']
+	v['shlib_CCFLAGS']       = ['-fPIC']
+	v['shlib_LINKFLAGS']     = ['-dynamiclib', '-compatibility_version', '1', '-current_version', '1']
 	v['shlib_PATTERN']       = 'lib%s.dylib'
 
 	v['staticlib_LINKFLAGS'] = []
diff --git a/third_party/waf/wafadmin/Tools/gxx.py b/third_party/waf/wafadmin/Tools/gxx.py
index 38e8d00..d57254d 100644
--- a/third_party/waf/wafadmin/Tools/gxx.py
+++ b/third_party/waf/wafadmin/Tools/gxx.py
@@ -92,8 +92,8 @@ def gxx_modifier_cygwin(conf):
 @conftest
 def gxx_modifier_darwin(conf):
 	v = conf.env
-	v['shlib_CXXFLAGS']      = ['-fPIC', '-compatibility_version', '1', '-current_version', '1']
-	v['shlib_LINKFLAGS']     = ['-dynamiclib']
+	v['shlib_CXXFLAGS']      = ['-fPIC']
+	v['shlib_LINKFLAGS']     = ['-dynamiclib', '-compatibility_version', '1', '-current_version', '1']
 	v['shlib_PATTERN']       = 'lib%s.dylib'
 
 	v['staticlib_LINKFLAGS'] = []
diff --git a/third_party/waf/wafadmin/Tools/osx.py b/third_party/waf/wafadmin/Tools/osx.py
index 95184ee..fef3a1a 100644
--- a/third_party/waf/wafadmin/Tools/osx.py
+++ b/third_party/waf/wafadmin/Tools/osx.py
@@ -162,6 +162,24 @@ def apply_bundle_remove_dynamiclib(self):
 		if not getattr(self, 'vnum', None):
 			try:
 				self.env['LINKFLAGS'].remove('-dynamiclib')
+
+				# Only try to remove these if -dynamiclib was preset, i.e. no exception above
+				try:
+				    arg_idx = self.env['LINKFLAGS'].index('-compatibility_version')
+				    self.env['LINKFLAGS'].pop(arg_idx) # the argument
+				    self.env['LINKFLAGS'].pop(arg_idx) # the subargument
+				except ValueError:
+				    pass
+				try:
+				    arg_idx = self.env['LINKFLAGS'].index('-current_version')
+				    self.env['LINKFLAGS'].pop(arg_idx) # the argument
+				    self.env['LINKFLAGS'].pop(arg_idx) # the subargument
+				except ValueError:
+				    pass
+			except ValueError:
+				pass
+
+			try:
 				self.env['LINKFLAGS'].remove('-single_module')
 			except ValueError:
 				pass
diff --git a/third_party/waf/wafadmin/Tools/python.py b/third_party/waf/wafadmin/Tools/python.py
index cd96b65..a9ad677 100644
--- a/third_party/waf/wafadmin/Tools/python.py
+++ b/third_party/waf/wafadmin/Tools/python.py
@@ -261,7 +261,7 @@ LDVERSION = %r
 	# under certain conditions, python extensions must link to
 	# python libraries, not just python embedding programs.
 	if (sys.platform == 'win32' or sys.platform.startswith('os2')
-		or sys.platform == 'darwin' or Py_ENABLE_SHARED):
+		or Py_ENABLE_SHARED):
 		env['LIBPATH_PYEXT'] = env['LIBPATH_PYEMBED']
 		env['LIB_PYEXT'] = env['LIB_PYEMBED']
 
