#!/bin/bash

# ===========================================================================================================================================================================
# non-makepkg-build.sh - A non-makepkg build script for wine-tkg-git
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#     Created by: Tk-Glitch <ti3nou at gmail dot com>
#
# This script replaces the wine-tkg PKGBUILD's function for use outside of makepkg or on non-pacman distros
#
# For command-line help, run this script with the -h|--help argument
#
# ./non-makepkg-build.sh -h
# ===========================================================================================================================================================================

pkgname=wine-tkg
_build_in_tmpfs="true"
_esyncsrcdir='esync'
_where="$PWD"

# Source common functions
_prepare_script="$_where/wine-tkg-scripts/prepare.sh"
_build_script="$_where/wine-tkg-scripts/build.sh"

if [[ ! -f "$_prepare_script" || ! -f "$_build_script" ]]; then
  error "Required script(s) missing in 'wine-tkg-scripts'. Expected:"
  error "  $_prepare_script"
  error "  $_build_script"
  error "Please ensure these files are available or update non-makepkg-build.sh to not depend on them."
  exit 1
fi

# shellcheck source=/dev/null
source "$_prepare_script"
# shellcheck source=/dev/null
source "$_build_script"

srcdir=""
_DEPSHELPER=${_DEPSHELPER:-0}
ACTION="build"

msg() { echo -e " \033[1;34m->\033[1;0m $1" >&2; }
msg2() { echo -e " \033[1;34m=>\033[1;0m \033[1;1m$1\033[1;0m" >&2; }
warning() { echo -e " \033[1;33m==> WARNING: $1\033[1;0m" >&2; }
error() { echo -e " \033[1;31m===> ERROR: $1\033[1;0m" >&2; }

nonuser_patcher() {
  if [ "$_NUKR" != "debug" ] || [[ "$_DEBUGANSW1" =~ [yY] ]]; then
    if [ "$_nopatchmsg" != "true" ]; then
      _fullpatchmsg=" -- ( $_patchmsg )"
    fi
    msg2 "Applying ${_patchname}"
    echo -e "\n${_patchname}${_fullpatchmsg}" >>"$_where"/prepare.log
    if [ -n "$_patchpath" ]; then
      if [ -f "${_patchpath%/*}"/mainline/"$_patchname" ] || [ -f "${_patchpath%/*}"/mainline/legacy/"$_patchname" ]; then
        _patchpath="${_patchpath%/*}/mainline/"
      elif [ -f "${_patchpath%/*}"/staging/"$_patchname" ] || [ -f "${_patchpath%/*}"/staging/legacy/"$_patchname" ]; then
        _patchpath="${_patchpath%/*}/staging/"
      fi
      if [ -e "${_patchpath%/*}"/"$_patchname" ]; then
        patch -Np1 <"${_patchpath%/*}"/"$_patchname" >>"$_where"/prepare.log || (error "Patch application has failed." && exit 1)
      elif [ -e "${_patchpath%/*}"/legacy/"$_patchname" ] || [ -e "${_patchpath}"/legacy/"$_patchname" ]; then
        patch -Np1 <"${_patchpath%/*}"/legacy/"$_patchname" >>"$_where"/prepare.log || (error "Patch application has failed." && exit 1)
      elif [ -e "$_where"/"$_patchname" ]; then
        warning "Falling back to root dir patching"
        patch -Np1 <"$_where"/"$_patchname" >>"$_where"/prepare.log || (error "Patch application has failed." && exit 1)
      else
        warning "Patch not found -- Skipping"
      fi
    else
      patch -Np1 <"$_where"/"$_patchname" >>"$_where"/prepare.log || (error "Patch application has failed." && exit 1)
    fi
    echo -e "${_patchname}${_fullpatchmsg}" >>"$_where"/last_build_config.log
  fi
}

_script_usage() {
  echo "$0 - A non-makepkg build script for wine-tkg-git"
  echo ""
  echo "Usage: $0 [args]"
  echo ""
  echo "  -d|--deps64 : Check for missing 64-bit dependencies"
  echo "  -e|--deps32 : Check for missing 32-bit dependencies"
  echo "  -c|--config <path> : Use a custom config file"
  echo ""
  exit 0
}

_script_parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -d|--deps64) _DEPSHELPER=1; ACTION="deps64"; shift 1 ;;
      -e|--deps32) _DEPSHELPER=1; ACTION="deps32"; shift 1 ;;
      -c|--config)
        if [ -z "$2" ]; then error "No path provided for custom config file!"; exit 1; fi
        _EXT_CONFIG_PATH="$(readlink -m -- "$2")"
        if [ ! -f "$_EXT_CONFIG_PATH" ]; then
          error "User-supplied external config file '${_EXT_CONFIG_PATH}' not found!"
          exit 1
        fi
        export _EXT_CONFIG_PATH
        shift 1 ;;
      *) _script_usage ;;
    esac
    shift
  done
}

_script_init() {
  msg2 "Non-makepkg build script will be used.\n"
  _init
  if [ "$_build_in_tmpfs" = "true" ]; then
    rm -rf "$_where"/src
    mkdir -p /tmp/wine-tkg/src
    ln -sfn /tmp/wine-tkg/src "$_where"/src
  else
    mkdir -p "$_where"/src
  fi
  srcdir="$_where"/src
  if [[ "$_nomakepkg_dependency_autoresolver" == "true" ]] && [ "$_DEPSHELPER" != "1" ]; then
    source "$_where"/wine-tkg-scripts/deps
    [[ "$_NOLIB64" != "true" ]] && install_deps "64" "${_ci_build}"
    [[ "$_NOLIB32" != "true" ]] && [ "$_NOLIB32" != "wow64" ] && install_deps "32" "${_ci_build}"
  fi
  _EXTERNAL_INSTALL="false"
  _faudio_ignorecheck="true"
  [ -z "$_localbuild" ] && _pkgnaming
  pkgname="${pkgname/-faudio-git/}"
}

_script_main() {
  case "$ACTION" in
    build) build_wine_tkg ;;
    deps64)
      _init
      mkdir -p "$_where"/src && srcdir="$_where"/src
      source "$_where"/wine-tkg-scripts/deps
      install_deps "64" "false"
      ;;
    deps32)
      _init
      mkdir -p "$_where"/src && srcdir="$_where"/src
      source "$_where"/wine-tkg-scripts/deps
      install_deps "32" "false"
      ;;
  esac
}

build_wine_tkg() {
  cd "$srcdir"
  touch "${_where}"/BIG_UGLY_FROGMINER
  if [ "$_SKIPBUILDING" != "true" ]; then
    msg2 "Cloning and preparing sources... Please be patient."
    if [ -z "$_localbuild" ]; then
      _prepare
    else
      _winesrcdir="$_localbuild"
      _use_staging="false"
      pkgname="$_localbuild"
      echo -e "Building local source $_localbuild" >"$_where"/prepare.log
    fi
  fi
  pkgver=$(pkgver)
  _polish
  _makedirs
  _prebuild_common
  local _prefix
  if [ -z "$_nomakepkg_prefix_path" ]; then
    _prefix="$_where/${pkgname}-${pkgver}"
  else
    _prefix="${_nomakepkg_prefix_path}/${pkgname}-${pkgver}"
  fi
  _configure_args64+=(--libdir="$_prefix/lib")
  _configure_args32+=(--libdir="$_prefix/lib32")
  [ "$_SKIPBUILDING" != "true" ] && [ "$_NOCOMPILE" != "true" ] && _build
  [ "$_NOCOMPILE" != "true" ] && _package_nomakepkg
}

pkgver() {
  if [ -d "${srcdir}/${_winesrcdir}" ]; then
    if [ "$_use_staging" = "true" ] && [ -d "${srcdir}/${_stgsrcdir}" ]; then
      cd "${srcdir}/${_stgsrcdir}"
    else
      cd "${srcdir}/${_winesrcdir}"
    fi
    _describe_wine
  fi
}

_script_parse_args "$@"
trap _exit_cleanup EXIT
_script_init
_script_main
