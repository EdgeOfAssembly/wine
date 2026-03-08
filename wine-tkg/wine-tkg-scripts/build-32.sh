#!/bin/bash

_exports_32() {
  if [ "$_NOCCACHE" != "true" ]; then
    if [ -e /usr/bin/ccache ]; then
      export CC="ccache gcc"
      export CXX="ccache g++"
    fi
    if [ -e /usr/bin/ccache ] && [ "$_NOMINGW" != "true" ]; then
      export CROSSCC="ccache i686-w64-mingw32-gcc" && echo "CROSSCC32 = ${CROSSCC}" >>"$_LAST_BUILD_CONFIG"
      export i386_CC="${CROSSCC}"
    fi
  fi
  if [ -d '/usr/lib32/pkgconfig' ]; then
    export PKG_CONFIG_PATH='/usr/lib32/pkgconfig:/usr/share/pkgconfig'
  elif [ -d '/usr/lib/i386-linux-gnu/pkgconfig' ]; then
    export PKG_CONFIG_PATH='/usr/lib/i386-linux-gnu/pkgconfig:/usr/share/pkgconfig'
  else
    export PKG_CONFIG_PATH='/usr/lib/pkgconfig:/usr/share/pkgconfig'
    CFLAGS+=" -I/usr/include/freetype2"
    CROSSCFLAGS+=" -I/usr/include/freetype2"
  fi
}

_configure_32() {
  msg2 'Configuring Wine-32...'
  cd "${srcdir}/${pkgname}"-32-build
  if [ "$_NUKR" != "debug" ] || [[ "$_DEBUGANSW3" =~ [yY] ]]; then
    if [ "$_NOLIB64" = "true" ]; then
      ../"${_winesrcdir}"/configure \
        --prefix="$_prefix" \
        "${_configure_args32[@]}" \
        "${_configure_args[@]}"
    else
      ../"${_winesrcdir}"/configure \
        --prefix="$_prefix" \
        "${_configure_args32[@]}" \
        "${_configure_args[@]}" \
        --with-wine64="${srcdir}/${pkgname}"-64-build
    fi
  fi
  if [ "$_pkg_strip" != "true" ]; then
    msg2 "Disable strip"
    sed 's|STRIP = strip|STRIP =|g' "${srcdir}/${pkgname}"-32-build/Makefile -i
  fi
}

_build_32() {
  msg2 'Building Wine-32...'
  cd "${srcdir}/${pkgname}"-32-build
  if [ "$_SINGLE_MAKE" = 'true' ]; then
    MAKEFLAGS="${MFLAGS#-j* }"
    exec "$@"
  elif [ "$_LOCAL_OPTIMIZED" = 'true' ]; then
    if [ "$_log_errors_to_file" = "true" ]; then
      make -j$(nproc) 2>"$_where/debug.log"
    else
      make -j$(nproc)
    fi
  else
    if [ "$_log_errors_to_file" = "true" ]; then
      make 2>"$_where/debug.log"
    else
      make
    fi
  fi
}
