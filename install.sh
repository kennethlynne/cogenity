#!/bin/sh
set -eu

repository=kennethlynne/cogenity
release_version=0.31.10
install_dir=${COGENITY_INSTALL_DIR:-"$HOME/.local/bin"}
operating_system=$(uname -s)
architecture=$(uname -m)

case "$operating_system:$architecture" in
  Darwin:arm64) asset=cogenity-darwin-arm64 ;;
  Darwin:x86_64) asset=cogenity-darwin-x64 ;;
  Linux:aarch64 | Linux:arm64) asset=cogenity-linux-arm64 ;;
  Linux:x86_64 | Linux:amd64) asset=cogenity-linux-x64-baseline ;;
  *)
    printf 'Unsupported platform: %s %s\n' "$operating_system" "$architecture" >&2
    exit 1
    ;;
esac

if [ "$operating_system" = Darwin ]; then
  macos_version=$(sw_vers -productVersion 2>/dev/null) || macos_version=
  macos_major=${macos_version%%.*}
  case "$macos_major" in
    '' | *[!0-9]*) macos_major=0 ;;
  esac
  if [ "$macos_major" -lt 13 ]; then
    printf 'macOS 13 or newer is required.\n' >&2
    exit 1
  fi
fi

if [ "$operating_system" = Linux ]; then
  libc_version=$(getconf GNU_LIBC_VERSION 2>/dev/null) || libc_version=
  case "$libc_version" in
    glibc\ *) ;;
    *)
      ldd_version=$(ldd --version 2>&1) || ldd_version=
      case "$ldd_version" in
        *musl*) printf 'musl Linux is unsupported; glibc is required.\n' >&2; exit 1 ;;
        *) printf 'glibc Linux is required.\n' >&2; exit 1 ;;
      esac
      ;;
  esac
fi

mkdir -p "$install_dir"
if [ -d "$install_dir/cogenity" ]; then
  printf 'Cannot replace %s/cogenity because it resolves to a directory.\n' "$install_dir" >&2
  exit 1
fi

temporary_dir=
staged_binary=
cleanup() {
  [ -z "$temporary_dir" ] || rm -rf "$temporary_dir"
  [ -z "$staged_binary" ] || rm -f "$staged_binary"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  else
    shasum -a 256 "$1" | awk '{ print $1 }'
  fi
}

temporary_dir=$(mktemp -d)
release_url="https://github.com/$repository/releases/download/v$release_version"
curl --proto '=https' --tlsv1.2 --fail --show-error --location \
  --connect-timeout 10 --max-time 60 \
  --output "$temporary_dir/$asset" "$release_url/$asset"
curl --proto '=https' --tlsv1.2 --fail --show-error --location \
  --connect-timeout 10 --max-time 60 \
  --output "$temporary_dir/SHA256SUMS" "$release_url/SHA256SUMS"

digest=$(awk -v asset="$asset" '$2 == asset { print $1 }' "$temporary_dir/SHA256SUMS")
case "$digest" in
  ????????????????????????????????????????????????????????????????) ;;
  *) printf 'Release checksum is missing or invalid for %s.\n' "$asset" >&2; exit 1 ;;
esac
[ "$(sha256_file "$temporary_dir/$asset")" = "$digest" ] || {
  printf 'Checksum verification failed for %s.\n' "$asset" >&2
  exit 1
}

staged_binary=$(mktemp "$install_dir/.cogenity.XXXXXX")
cp "$temporary_dir/$asset" "$staged_binary"
chmod 755 "$staged_binary"
installed_version=$("$staged_binary" --version 2>/dev/null) || installed_version=
[ "$installed_version" = "$release_version" ] || {
  printf 'Downloaded Cogenity reports version %s, expected %s.\n' \
    "${installed_version:-unknown}" "$release_version" >&2
  exit 1
}
trap '' HUP INT TERM
mv -f "$staged_binary" "$install_dir/cogenity"
staged_binary=
rm -rf "$install_dir/.cogenity"
trap 'exit 1' HUP INT TERM

printf 'Installed Cogenity at %s/cogenity\n' "$install_dir"
case ":$PATH:" in
  *:"$install_dir":*) ;;
  *) printf 'Add %s to PATH before running cogenity.\n' "$install_dir" ;;
esac
