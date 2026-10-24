#!/bin/sh
# Installs the CLI: curl -fsSL https://raw.githubusercontent.com/herewecloud/sailops-sandbox/main/install.sh | sh
# Optional branded mirror: https://sailops.io/install-sandbox.sh
#
# Downloads the release archive for this machine from the releases of the
# public repository herewecloud/sailops-sandbox (or SAILOPS_SANDBOX_RELEASE_URL)
# into /usr/local/bin when it is writable, else ~/.local/bin.
# SAILOPS_SANDBOX_VERSION pins a release such as v0.1.0 (the tag of that
# repository, without the sailops-sandbox- prefix of the monorepo tag).
set -eu

RELEASE_URL="${SAILOPS_SANDBOX_RELEASE_URL:-https://github.com/herewecloud/sailops-sandbox/releases}"
VERSION="${SAILOPS_SANDBOX_VERSION:-latest}"

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$os" in
    linux|darwin) ;;
    *) echo "sailops-sandbox: unsupported OS $os (linux and darwin are built)" >&2; exit 1 ;;
esac

arch="$(uname -m)"
case "$arch" in
    x86_64|amd64) arch=amd64 ;;
    arm64|aarch64) arch=arm64 ;;
    *) echo "sailops-sandbox: unsupported architecture $arch" >&2; exit 1 ;;
esac

if [ "$VERSION" = "latest" ]; then
    url="$RELEASE_URL/latest/download/sailops-sandbox_${os}_${arch}.tar.gz"
else
    case "$VERSION" in
        v*) ;;
        *) VERSION="v$VERSION" ;;
    esac
    url="$RELEASE_URL/download/${VERSION}/sailops-sandbox_${os}_${arch}.tar.gz"
fi

if [ -w /usr/local/bin ]; then
    target_dir=/usr/local/bin
else
    target_dir="${HOME}/.local/bin"
    mkdir -p "$target_dir"
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "downloading $url"
curl -fsSL "$url" -o "$tmp/sailops-sandbox.tar.gz"
curl -fsSL "${url%/*}/checksums.txt" -o "$tmp/checksums.txt"
archive="sailops-sandbox_${os}_${arch}.tar.gz"
expected="$(awk -v archive="$archive" '$2 == archive { print $1 }' "$tmp/checksums.txt")"
case "$expected" in
    ''|*[!0-9a-f]*) echo "sailops-sandbox: invalid release checksum" >&2; exit 1 ;;
esac
[ "${#expected}" -eq 64 ] || { echo "sailops-sandbox: invalid release checksum" >&2; exit 1; }
if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$tmp/sailops-sandbox.tar.gz" | awk '{ print $1 }')"
elif command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "$tmp/sailops-sandbox.tar.gz" | awk '{ print $1 }')"
else
    echo "sailops-sandbox: sha256sum or shasum is required" >&2
    exit 1
fi
[ "$actual" = "$expected" ] || { echo "sailops-sandbox: release checksum mismatch; nothing installed" >&2; exit 1; }
tar -C "$tmp" -xzf "$tmp/sailops-sandbox.tar.gz"
install -m 0755 "$tmp/sailops-sandbox" "$target_dir/sailops-sandbox"

echo "installed $target_dir/sailops-sandbox"

case ":$PATH:" in
    *":$target_dir:"*) ;;
    *) echo "add $target_dir to your PATH, e.g. export PATH=\"$target_dir:\$PATH\"" ;;
esac

echo "next: sailops-sandbox init"
