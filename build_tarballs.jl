using BinaryBuilder

# Collection of sources required to build Glib
sources = [
    "https://ftp.gnome.org/pub/gnome/sources/glib/2.54/glib-2.54.2.tar.xz" =>
    "bb89e5c5aad33169a8c7f28b45671c7899c12f74caf707737f784d7102758e6c",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd glib-2.54.2/

# Provide answers to a few configure questions automatically
cat > glib.cache <<END
glib_cv_stack_grows=no
glib_cv_uscore=no
ac_cv_path_MSGFMT=$prefix/bin/msgfmt
END

./configure LDFLAGS=-L$prefix/lib CPPFLAGS=-I$prefix/include --enable-libmount=no --cache-file=glib.cache --prefix=$prefix --host=$target

make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
    BinaryProvider.Linux(:x86_64, :glibc),
    BinaryProvider.Linux(:aarch64, :glibc),
    BinaryProvider.Linux(:armv7l, :glibc),
    BinaryProvider.Linux(:powerpc64le, :glibc),
    BinaryProvider.MacOS(),
    # gettext doesn't build on windows yet :(
    #BinaryProvider.Windows(:i686),
    #BinaryProvider.Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libglib", :libglib)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    # We need zlib
    "https://github.com/staticfloat/ZlibBuilder/releases/download/v1.2.11-3/build.jl",
    # We need libffi
    "https://github.com/staticfloat/libffiBuilder/releases/download/v3.2.1-0/build.jl",
    # We need gettext
    "https://github.com/staticfloat/GettextBuilder/releases/download/v0.19.8-0/build.jl",
    # We need pcre
    "https://github.com/staticfloat/PcreBuilder/releases/download/v8.41-0/build.jl",
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "Glib", sources, script, platforms, products, dependencies)
