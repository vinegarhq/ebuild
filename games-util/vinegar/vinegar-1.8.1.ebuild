# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module xdg

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vinegarhq/vinegar.git"
else
	SRC_URI="https://github.com/vinegarhq/vinegar/releases/download/v${PV}/vinegar-v${PV}.tar.xz"
	KEYWORDS="amd64"
	S="${WORKDIR}/${PN}-v${PV}"
fi

DESCRIPTION="An open-source, minimal, configurable, fast bootstrapper for running Roblox on Linux"
HOMEPAGE="https://vinegarhq.org"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="
    gui-libs/gtk:4
    gui-libs/libadwaita
"
DEPEND="${RDEPEND}"
BDEPEND="
    >=dev-lang/go-1.22
"

src_unpack() {
	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
		go-module_live_vendor
	else
		go-module_src_unpack
	fi
}

src_compile() {
    emake vinegar
}

src_install() {
    emake DESTDIR="${D}" PREFIX="/usr" install
}

pkg_postinst() {
    xdg_desktop_database_update
}

pkg_postrm() {
    xdg_desktop_database_update
}
