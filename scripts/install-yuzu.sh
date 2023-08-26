#!/usr/bin/env bash
###
# File: install-yuzu.sh
# Project: scripts
# File Created: Wednesday, 23rd August 2023 7:16:02 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Saturday, 26th August 2023 2:42:30 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###
#
# About:
#   Install Yuzu during container startup.
#   This will also configure Yuzu with some default options for Steam Headless.
#
# Guide:
#   Add this script to your startup scripts by running:
#       $ ln -sf "${USER_HOME:?}/init.d/scripts/install-yuzu.sh" "${USER_HOME:?}/init.d/install-yuzu.sh"
#
###


# Config
package_name="Yuzu"
package_description="Nintendo Switch Emulator"
package_icon_url="https://raw.githubusercontent.com/yuzu-emu/yuzu-assets/master/icons/icon.png"
package_executable="${USER_HOME:?}/Applications/${package_name:?}.AppImage"
package_category="Game"
package_icon="${USER_HOME:?}/.cache/init.d/package_icons/${package_name:?}-icon.png"


[[ -f "${USER_HOME:?}/init.d/helpers/setup-directories.sh" ]] && source "${USER_HOME:?}/init.d/helpers/setup-directories.sh"
[[ -f "${USER_HOME:?}/init.d/helpers/functions.sh" ]] && source "${USER_HOME:?}/init.d/helpers/functions.sh"
print_package_name


# Check for a new version to install
__registry_package_json=$(wget -O - -o /dev/null https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases/latest)
__latest_package_version=$(echo ${__registry_package_json:?} | jq -r ".assets[2] | .name" | cut -d "-" -f 3 | cut -d "." -f 1)
__latest_package_id=$(echo ${__registry_package_json:?} | jq -r ".assets[2] | .name" | cut -d "-" -f 2,3)
print_step_header "Latest ${package_name:?} version: ${__latest_package_version:?}"


# Only install if the latest version does not already exist locally
if [[ ! -f "${USER_HOME:?}/.cache/init.d/installed_packages/.${package_name:?}-${__latest_package_version:?}" ]]; then
    # Fetch download links
    print_step_header "Fetching download link for ${package_name:?} version ${__latest_package_version:?}"
    __latest_url=$(wget -O - -o /dev/null https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases/latest | jq -r ".assets[2] | .browser_download_url")

    # Download Appimage to Applications directory
    print_step_header "Downloading ${package_name:?} version ${__latest_package_version:?}"
    fetch_appimage_and_make_executable "${__latest_url:?}"

    # Ensure this package has a start menu link (will create it if missing)
    print_step_header "Ensuring menu short is present for ${package_name:?}"
    ensure_menu_shortcut

    # Mark this version as installed
    touch "${USER_HOME:?}/.cache/init.d/installed_packages/.${package_name:?}-${__latest_package_version:?}"
else
    print_step_header "Latest version of ${package_name:?} version ${__latest_package_version:?} already installed"
fi

[[ -f "${USER_HOME:?}/init.d/helpers/configure-yuzu.sh" ]] && source "${USER_HOME:?}/init.d/helpers/configure-yuzu.sh"

echo "DONE"
