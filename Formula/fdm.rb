class Fdm < Formula
  desc "Program to fetch and deliver mail"
  homepage "https://github.com/nicm/fdm"

  # head "https://github.com/nicm/fdm.git"

  # stable do

  url "https://github.com/nicm/fdm/releases/download/1.9/fdm-1.9.tar.gz"
  sha256 "16416c38a9a7e32d187220cc5ae61a51463d5e4e47419c5c513f422523d39914"

  # TODO: Support for OpenSSL 1.0 API, already merged upstream
  patch :DATA

  # end

  # TODO: remove these two deps from stable but keep them for head, once patch
  # to configure.ac and autoreconf is gone
  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "openssl"
  depends_on "tdb"

  def install
    # if build.stable?
    # TODO: Remove this once the patch to configure.ac is not needed
    system "autoreconf", "-fi"
    # elsif build.head?
    #   ENV.deparallelize # lex.c->parse.h dependency appears to be broken in HEAD
    #   system "./autogen.sh"
    # end

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "echo account '\"test\"' maildir '\"/tmp/testmaildir\"' > fdm.conf"
    chmod(0600, "fdm.conf")
    system "#{bin}/fdm", "-n", "-f", "fdm.conf"
  end
end

__END__
From 070cee8d1efba1ca260777a204fba7cdfe676ca5 Mon Sep 17 00:00:00 2001
From: Nicholas Marriott <nicholas.marriott@gmail.com>
Date: Tue, 17 Jan 2017 23:14:03 +0000
Subject: [PATCH] Look for OPENSSL_init_ssl, from Tomasz Miasko.

---
 configure.ac | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 5793c2d..161040c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -93,11 +93,16 @@ if test "x$found_libcrypto" = xno; then
 	AC_MSG_ERROR("libcrypto not found")
 fi
 AC_SEARCH_LIBS(
-	SSL_library_init,
+	OPENSSL_init_ssl,
 	[ssl],
 	found_libssl=yes,
 	found_libssl=no
 )
+AC_SEARCH_LIBS(
+	SSL_library_init,
+	[ssl],
+	found_libssl=yes
+)
 if test "x$found_libssl" = xno; then
 	AC_MSG_ERROR("libssl not found")
 fi
