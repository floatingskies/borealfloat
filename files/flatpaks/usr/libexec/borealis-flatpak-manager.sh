#!/usr/bin/bash
# Installs the Borealis default Flatpaks on first boot. The live ISO boots this
# same image, so it also populates the live session and every freshly installed
# system.
#
# Configure by editing /etc/flatpak/install and /etc/flatpak/remove (one app-id
# per line; '#' comments and blank lines are ignored).
#
# A stamp is written under /var, so this runs once per image. /var is reset by
# `bootc switch` (rebase), which is intentional: after rebasing to a new base,
# the default Flatpaks are installed again automatically.
set -euo pipefail

INSTALL_LIST=/etc/flatpak/install
REMOVE_LIST=/etc/flatpak/remove
STAMP=/var/lib/borealis/flatpaks.done

[[ -f "${INSTALL_LIST}" ]] || {
    echo "borealis-flatpak-manager: no ${INSTALL_LIST}, nothing to do"
    exit 0
}
[[ -e "${STAMP}" ]] && exit 0

ids=()
while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%%\#*}"
    line="${line//[[:space:]]/}"
    [[ -n "${line}" ]] && ids+=("${line}")
done < "${INSTALL_LIST}"
if [[ ${#ids[@]} -eq 0 ]]; then
    echo "borealis-flatpak-manager: ${INSTALL_LIST} has no entries, nothing to do"
    exit 0
fi

flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

# Optional convergence list: uninstall anything listed here.
if [[ -f "${REMOVE_LIST}" ]]; then
    while IFS= read -r line || [[ -n "${line}" ]]; do
        line="${line%%\#*}"
        line="${line//[[:space:]]/}"
        [[ -n "${line}" ]] && flatpak uninstall --system --noninteractive "${line}" >/dev/null 2>&1 || true
    done < "${REMOVE_LIST}"
fi

echo "borealis-flatpak-manager: installing ${#ids[@]} flatpak(s)"
flatpak install --system --noninteractive --assumeyes flathub "${ids[@]}"

mkdir -p "$(dirname "${STAMP}")"
touch "${STAMP}"
echo "borealis-flatpak-manager: done (${STAMP})"