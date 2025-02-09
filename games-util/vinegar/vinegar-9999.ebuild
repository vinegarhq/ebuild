# Copyright 1999-2024 Gentoo Authors
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
HOMEPAGE="https://vinegarhq.github.io"

LICENSE="GPL-3"
SLOT="0"
IUSE="+X wayland pie vulkan +system-wine video_cards_nvidia"

REQUIRED_USE="video_cards_nvidia? ( !wayland )"

RDEPEND="
    system-wine? ( virtual/wine )
    gui-libs/gtk:4
    gui-libs/libadwaita
"
DEPEND="${RDEPEND}"
BDEPEND="
    >=dev-lang/go-1.21
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
    GOFLAGS="${GOFLAGS}"
    if use pie ; then
        GOFLAGS+=" -buildmode=pie"
    fi
    VINEGAR_GOFLAGS=""
    if ! use X ; then
        VINEGAR_GOFLAGS+=" nox11"
    fi
    if ! use wayland ; then
        VINEGAR_GOFLAGS+=" nowayland"
    fi
    if ! use vulkan ; then
        VINEGAR_GOFLAGS+=" novulkan"
    fi
    if ! (use X || use wayland) ; then
        VINEGAR_GOFLAGS+=" nogui"
    fi
    if ! [ -z "$VINEGAR_GOFLAGS" ] ; then
        VINEGAR_GOFLAGS="-tags \"${VINEGAR_GOFLAGS}\""
    fi
    emake VINEGAR_GOFLAGS="${VINEGAR_GOFLAGS}" vinegar
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
