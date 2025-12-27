#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/krzysztofzablocki/Sourcery"
TOOL_NAME="sourcery"
TOOL_TEST="sourcery --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

# Detect platform and return download details
# Returns: "macos" | "ubuntu-22.04" or fails
get_platform() {
	local kernel
	kernel="$(uname -s)"

	case "$kernel" in
		Darwin)
			echo "macos"
			;;
		Linux)
			# Check if Ubuntu 22.04
			if [ -f /etc/os-release ]; then
				# shellcheck source=/dev/null
				source /etc/os-release
				if [ "$ID" = "ubuntu" ] && [ "$VERSION_ID" = "22.04" ]; then
					echo "ubuntu-22.04"
					return
				fi
			fi
			fail "Unsupported Linux distribution. Only Ubuntu 22.04 is supported."
			;;
		*)
			fail "Unsupported OS: $kernel"
			;;
	esac
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//'
}

list_all_versions() {
	list_github_tags
}

ignore_invalid_versions() {
	# drop first 5 versions after sorting
	# 0.1.0 0.1.1 0.2.0 0.2.1 0.2.2
	# version 0.3.0 is downloadable
	cut -d ' ' -f 6-
}

# Fetch Ubuntu asset URL from GitHub API
# Pattern: finds asset matching *ubuntu*22.04*{arch}*.tar.xz
get_ubuntu_asset_url() {
	local version="$1"
	local api_url asset_url arch api_response

	arch="$(uname -m)"
	api_url="https://api.github.com/repos/krzysztofzablocki/Sourcery/releases/tags/${version}"

	api_response=$(curl -sL "$api_url" 2>&1)

	asset_url=$(echo "$api_response" | \
		grep -o '"browser_download_url": *"[^"]*ubuntu[^"]*22\.04[^"]*'"${arch}"'[^"]*\.tar\.xz"' | \
		head -1 | \
		sed 's/"browser_download_url": *"\([^"]*\)"/\1/')

	if [ -z "$asset_url" ]; then
		fail "Could not find Ubuntu 22.04 $arch asset for version $version"
	fi

	echo "$asset_url"
}

download_release() {
	local version filename url platform
	version="$1"
	filename="$2"
	platform="$(get_platform)"

	case "$platform" in
		macos)
			url="$GH_REPO/releases/download/${version}/sourcery-${version}.zip"
			;;
		ubuntu-22.04)
			url="$(get_ubuntu_asset_url "$version")"
			;;
	esac

	echo "* Downloading $TOOL_NAME release $version..."
	curl -fsSL -o "$filename" "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		
		# Handle different archive structures per platform
		local platform
		platform="$(get_platform)"
		
		case "$platform" in
			macos)
				# macOS archive has bin/sourcery
				cp -r "${ASDF_DOWNLOAD_PATH}/bin/${TOOL_NAME}" "$install_path"
				;;
			ubuntu-22.04)
				# Ubuntu archive has sourcery at root
				cp -r "${ASDF_DOWNLOAD_PATH}/${TOOL_NAME}" "$install_path"
				;;
		esac

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
